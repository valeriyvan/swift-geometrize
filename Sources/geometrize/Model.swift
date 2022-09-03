import Foundation

// Type alias for a function that is used to decide whether or not to finally add a shape to the image
// @param lastScore The image similarity score prior to adding the shape
// @param newScore What the image similarity score would be after adding the shape
// @param shape The shape that this function shall decide whether to add
// @param lines The scanlines for the pixels in the shape
// @param color The colour of the shape
// @param before The image prior to adding the shape
// @param after The image as it would be after adding the shape
// @param target The image that we are trying to replicate
// @return True to add the shape to the image, false not to
typealias ShapeAcceptancePreconditionFunction = (
    _ lastScore: Double,
    _ newScore: Double,
    _ shape: any Shape,
    _ lines: [Scanline],
    _ color: Rgba,
    _ before: Bitmap,
    _ after: Bitmap,
    _ target: Bitmap
) -> Bool

func defaultAddShapePrecondition(
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

// The Model class is the model for the core optimization/fitting algorithm.
struct Model {
    
    // Creates a model that will aim to replicate the target bitmap with shapes.
    // @param target The target bitmap to replicate with shapes.
    init(target: Bitmap) {
        m_target = target
        m_current = Bitmap(width: target.width, height: target.height, color: m_target.averageColor())
        m_lastScore = differenceFull(first: m_target, second: m_current)
        m_baseRandomSeed = 0
        m_randomSeedOffset = 0
    }

    // Creates a model that will optimize for the given target bitmap, starting from the given initial bitmap.
    // The target bitmap and initial bitmap must be the same size (width and height).
    // @param target The target bitmap to replicate with shapes.
    // @param initial The starting bitmap.
    init(target: Bitmap, initial: Bitmap) {
        m_target = target
        m_current = initial
        m_lastScore = differenceFull(first: m_target, second: m_current)
        m_baseRandomSeed = 0
        m_randomSeedOffset = 0
        assert(m_target.width == m_current.width)
        assert(m_target.height == m_current.height)
    }

    // Resets the model back to the state it was in when it was created.
    // @param backgroundColor The starting background color to use.
    mutating func reset(backgroundColor: Rgba) {
        m_current.fill(color: backgroundColor)
        m_lastScore = differenceFull(first: m_target, second: m_current);
    }

    var width: Int { m_target.width }
    var height: Int { m_target.height }

    private mutating func getHillClimbState(
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
        let seed = m_baseRandomSeed + m_randomSeedOffset
        m_randomSeedOffset += 1
        seedRandomGenerator(seed)

        let lastScore = m_lastScore
        
        var buffer: Bitmap = m_current
        let state = bestHillClimbState(shapeCreator: shapeCreator, alpha: UInt(alpha), n: shapeCount, age: maxShapeMutations, target: m_target, current: m_current, buffer: &buffer, lastScore: lastScore, customEnergyFunction: energyFunction)
        
        return [state]
    }

    // Steps the primitive optimization/fitting algorithm.
    // @param shapeCreator A function that will produce the shapes.
    // @param alpha The alpha of the shape.
    // @param shapeCount The number of random shapes to generate (only 1 is chosen in the end).
    // @param maxShapeMutations The maximum number of times to mutate each random shape.
    // @param maxThreads The maximum number of threads to use during this step.
    // @param energyFunction An optional function to calculate the energy (if unspecified a default implementation is used).
    // @param addShapePrecondition An optional function to determine whether to accept a shape (if unspecified a default implementation is used).
    // @return A vector containing data about the shapes added to the model in this step. This may be empty if no shape that improved the image could be found.
    mutating func step(
        shapeCreator: () -> any Shape,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: UInt32,
        maxThreads: Int,
        energyFunction: @escaping EnergyFunction,
        addShapePrecondition: @escaping ShapeAcceptancePreconditionFunction
    ) -> [ShapeResult] {
        
        let states: [State] = getHillClimbState(shapeCreator: shapeCreator, alpha: alpha, shapeCount: UInt(shapeCount), maxShapeMutations: maxShapeMutations, maxThreads: maxThreads, energyFunction: energyFunction)

        guard !states.isEmpty else {
            fatalError("Failed to get a hill climb state.")
        }

        // State with min score
        guard let it = states.min(by: { $0.m_score < $1.m_score }) else {
            fatalError("Failed to get a state with min score.")
        }
        
        // Draw the shape onto the image
        let shape = it.m_shape
        let lines: [Scanline] = shape.rasterize()
        let color: Rgba = computeColor(target: m_target, current: m_current, lines: lines, alpha: alpha)
        let before: Bitmap = m_current
        m_current.draw(lines: lines, color: color)

        // Check for an improvement - if not, roll back and return no result
        let newScore: Double = differencePartial(target: m_target, before: before, after: m_current, score: m_lastScore, lines: lines)
        let addShapeCondition = addShapePrecondition ?? defaultAddShapePrecondition
        guard addShapeCondition(m_lastScore, newScore, shape, lines, color, before, m_current, m_target) else {
            m_current = before
            return []
        }

        // Improvement - set new baseline and return the new shape
        m_lastScore = newScore
        
        let result: ShapeResult = ShapeResult(score: m_lastScore, color: color, shape: shape)
        return [result]
    }

    // Draws a shape on the model. Typically used when to manually add a shape to the image
    // (e.g. when setting an initial background).
    // NOTE this unconditionally draws the shape, even if it increases the difference between
    // the source and target image.
    // @param shape The shape to draw.
    // @param color The color (including alpha) of the shape.
    // @return Data about the shape drawn on the model.
    mutating func draw(shape: any Shape, color: Rgba) -> ShapeResult {
        let lines: [Scanline] = shape.rasterize()
        let before: Bitmap = m_current
        m_current.draw(lines: lines, color: color)
        m_lastScore = differencePartial(target: m_target, before: before, after: m_current, score: m_lastScore, lines: lines)
        return ShapeResult(score: m_lastScore, color: color, shape: shape)
    }

     // Gets the target bitmap.
     // @return The target bitmap.
    func getTarget() -> Bitmap { m_target }

    // Sets the seed that the random number generators of this model use.
    // Note that the model also uses an internal seed offset which is incremented when the model is stepped.
    // @param seed The random number generator seed.
    mutating func setSeed(_ seed: Int) {
        m_baseRandomSeed = seed
    }

    // The target bitmap, the bitmap we aim to approximate.
    private var m_target: Bitmap
    
    // The current bitmap.
    private var m_current: Bitmap
    
    // Score derived from calculating the difference between bitmaps.
    var m_lastScore: Double
    
    private static let defaultMaxThreads: Int = 4
    
    // The base value used for seeding the random number generator (the one the user has control over)
    var m_baseRandomSeed: Int // TODO: atomic
    
    // Seed used for random number generation.
    // Note: incremented by each std::async call used for model stepping.
    var m_randomSeedOffset: Int // TODO: atomic

}
