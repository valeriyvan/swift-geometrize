import Foundation

/// Type alias for a function that is used to decide whether or not to finally add a shape to the image.
/// - Parameters:
///   - lastScore The image similarity score prior to adding the shape.
///   - newScore What the image similarity score would be after adding the shape.
///   - shape The shape that this function shall decide whether to add.
///   - lines The scanlines for the pixels in the shape.
///   - color The colour of the shape.
///   - before The image prior to adding the shape.
///   - after The image as it would be after adding the shape
///   - target The image that we are trying to replicate.
/// - Returns: True to add the shape to the image, false not to.
public typealias ShapeAcceptancePreconditionFunction = (
    _ lastScore: Double,
    _ newScore: Double,
    _ shape: any Shape,
    _ lines: [Scanline],
    _ color: Rgba,
    _ before: Bitmap,
    _ after: Bitmap,
    _ target: Bitmap
) -> Bool

public func defaultAddShapePrecondition( // swiftlint:disable:this function_parameter_count
    lastScore: Double,
    newScore: Double,
    shape: any Shape,
    lines: [Scanline],
    color: Rgba,
    _: Bitmap,
    _: Bitmap,
    _: Bitmap
) -> Bool {
    newScore < lastScore; // Adds the shape if the score improved (that is: the difference decreased)
}

/// The Model class is the model for the core optimization/fitting algorithm.
struct Model {

    /// Creates a model that will aim to replicate the target bitmap with shapes.
    /// - Parameter targetBitmap: The target bitmap to replicate with shapes.
    init(targetBitmap: Bitmap) {
        self.targetBitmap = targetBitmap
        currentBitmap = Bitmap(width: targetBitmap.width, height: targetBitmap.height, color: targetBitmap.averageColor())
        lastScore = differenceFull(first: targetBitmap, second: currentBitmap)
        baseRandomSeed = 0
        randomSeedOffset = 0
    }

    /// Creates a model that will optimize for the given target bitmap, starting from the given initial bitmap.
    /// The target bitmap and initial bitmap must be the same size (width and height).
    /// - Parameters:
    ///   - target: The target bitmap to replicate with shapes.
    ///   - initial: The starting bitmap.
    init(target: Bitmap, initial: Bitmap) {
        targetBitmap = target
        currentBitmap = initial
        lastScore = differenceFull(first: target, second: currentBitmap)
        baseRandomSeed = 0
        randomSeedOffset = 0
        assert(target.width == currentBitmap.width)
        assert(target.height == currentBitmap.height)
    }

    /// Resets the model back to the state it was in when it was created.
    /// - Parameter backgroundColor: The starting background color to use.
    mutating func reset(backgroundColor: Rgba) {
        currentBitmap.fill(color: backgroundColor)
        lastScore = differenceFull(first: targetBitmap, second: currentBitmap)
    }

    var width: Int { targetBitmap.width }
    var height: Int { targetBitmap.height }

    private mutating func getHillClimbState( // swiftlint:disable:this function_parameter_count
        shapeCreator: () -> any Shape,
        alpha: UInt8,
        shapeCount: UInt,
        maxShapeMutations: UInt32,
        maxThreads: Int, // Ignored. Single thread is used at the moment.
        energyFunction: @escaping EnergyFunction
    ) -> [State] {
        // Ensure that the results of the random generation are the same between tasks with identical settings
        // The RNG is thread-local and std::async may use a thread pool (which is why this is necessary)
        // Note this implementation requires maxThreads to be the same between tasks for each task to produce the same results.
        let seed = baseRandomSeed + randomSeedOffset
        randomSeedOffset += 1
        seedRandomGenerator(UInt64(seed))

        let lastScore = lastScore

        var buffer: Bitmap = currentBitmap
        let state = bestHillClimbState(
            shapeCreator: shapeCreator,
            alpha: UInt(alpha),
            n: shapeCount,
            age: maxShapeMutations,
            target: targetBitmap,
            current: currentBitmap,
            buffer: &buffer,
            lastScore: lastScore,
            customEnergyFunction: energyFunction
        )

        return [state]
    }

    /// Steps the primitive optimization/fitting algorithm.
    /// - Parameters:
    ///   - shapeCreator: A function that will produce the shapes.
    ///   - alpha: The alpha of the shape.
    ///   - shapeCount: The number of random shapes to generate (only 1 is chosen in the end).
    ///   - maxShapeMutations: The maximum number of times to mutate each random shape.
    ///   - maxThreads: The maximum number of threads to use during this step.
    ///   - energyFunction: An optional function to calculate the energy (if unspecified a default implementation is used).
    ///   - addShapePrecondition: An optional function to determine whether to accept a shape
    ///     (if unspecified a default implementation is used).
    /// - Returns: A vector containing data about the shapes added to the model in this step.
    ///     This may be empty if no shape that improved the image could be found.
    mutating func step( // swiftlint:disable:this function_parameter_count
        shapeCreator: () -> any Shape,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: UInt32,
        maxThreads: Int,
        energyFunction: @escaping EnergyFunction,
        addShapePrecondition: @escaping ShapeAcceptancePreconditionFunction
    ) -> [ShapeResult] {

        let states: [State] = getHillClimbState(
            shapeCreator: shapeCreator,
            alpha: alpha,
            shapeCount: UInt(shapeCount),
            maxShapeMutations: maxShapeMutations,
            maxThreads: maxThreads,
            energyFunction: energyFunction
        )

        guard !states.isEmpty else {
            fatalError("Failed to get a hill climb state.")
        }

        // State with min score
        guard let it = states.min(by: { $0.score < $1.score }) else {
            fatalError("Failed to get a state with min score.")
        }

        // Draw the shape onto the image
        let shape = it.shape.copy()
        let lines: [Scanline] = shape.rasterize()
        let color: Rgba = computeColor(target: targetBitmap, current: currentBitmap, lines: lines, alpha: alpha)
        let before: Bitmap = currentBitmap
        currentBitmap.draw(lines: lines, color: color)

        // Check for an improvement - if not, roll back and return no result
        let newScore: Double = differencePartial(target: targetBitmap, before: before, after: currentBitmap, score: lastScore, lines: lines)
        let addShapeCondition = addShapePrecondition ?? defaultAddShapePrecondition
        guard addShapeCondition(lastScore, newScore, shape, lines, color, before, currentBitmap, targetBitmap) else {
            currentBitmap = before
            return []
        }

        // Improvement - set new baseline and return the new shape
        lastScore = newScore

        let result: ShapeResult = ShapeResult(score: lastScore, color: color, shape: shape)
        return [result]
    }

    /// Draws a shape on the model. Typically used when to manually add a shape to the image (e.g. when setting an initial background).
    /// NOTE this unconditionally draws the shape, even if it increases the difference between the source and target image.
    /// - Parameters:
    ///   - shape: The shape to draw.
    ///   - color: The color (including alpha) of the shape.
    /// - Returns: Data about the shape drawn on the model.
    mutating func draw(shape: any Shape, color: Rgba) -> ShapeResult {
        let lines: [Scanline] = shape.rasterize()
        let before: Bitmap = currentBitmap
        currentBitmap.draw(lines: lines, color: color)
        lastScore = differencePartial(target: targetBitmap, before: before, after: currentBitmap, score: lastScore, lines: lines)
        return ShapeResult(score: lastScore, color: color, shape: shape)
    }

    /// Gets the target bitmap.
    /// - Returns: The target bitmap.
    func getTarget() -> Bitmap { targetBitmap }

    /// Sets the seed that the random number generators of this model use.
    /// Note that the model also uses an internal seed offset which is incremented when the model is stepped.
    /// - Parameter seed: The random number generator seed.
    mutating func setSeed(_ seed: Int) {
        baseRandomSeed = seed
    }

    /// The target bitmap, the bitmap we aim to approximate.
    private var targetBitmap: Bitmap

    /// The current bitmap.
    private var currentBitmap: Bitmap

    /// Score derived from calculating the difference between bitmaps.
    var lastScore: Double

    private static let defaultMaxThreads: Int = 4

    /// The base value used for seeding the random number generator (the one the user has control over)
    var baseRandomSeed: Int // TODO: atomic

    /// Seed used for random number generation.
    /// Note: incremented by each std::async call used for model stepping.
    var randomSeedOffset: Int // TODO: atomic

}
