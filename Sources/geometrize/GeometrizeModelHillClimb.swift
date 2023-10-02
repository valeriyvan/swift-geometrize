import Foundation

/// The model class is the model for the core optimization/fitting algorithm.
class GeometrizeModelHillClimb: GeometrizeModelBase {

    // Runs concurrently maxThreads optimization sessions and returns array of optimization results.
    // step function then takes the only result with the best score.
    // Therefore it does make sense decrease shapeCount proportionally when increasing maxThreads
    // to achieve same effectiveness.
    private func getHillClimbState( // swiftlint:disable:this function_parameter_count
        shapeCreator: () -> any Shape,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: Int,
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
            alpha: alpha,
            n: shapeCount,
            age: maxShapeMutations,
            target: targetBitmap,
            current: currentBitmap,
            buffer: &buffer,
            lastScore: lastScore,
            energyFunction: energyFunction
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
    ///   - energyFunction: A function to calculate the energy.
    ///   - addShapePrecondition: A function to determine whether to accept a shape.
    /// - Returns: A vector containing data about the shapes added to the model in this step.
    ///     This may be empty if no shape that improved the image could be found.
    func step( // swiftlint:disable:this function_parameter_count
        shapeCreator: () -> any Shape,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: Int,
        maxThreads: Int,
        energyFunction: @escaping EnergyFunction,
        addShapePrecondition: @escaping ShapeAcceptancePreconditionFunction = defaultAddShapePrecondition
    ) -> [ShapeResult] {

        let states: [State] = getHillClimbState(
            shapeCreator: shapeCreator,
            alpha: alpha,
            shapeCount: shapeCount,
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
        guard addShapePrecondition(lastScore, newScore, shape, lines, color, before, currentBitmap, targetBitmap) else {
            currentBitmap = before
            return []
        }

        // Improvement - set new baseline and return the new shape
        lastScore = newScore

        let result: ShapeResult = ShapeResult(score: lastScore, color: color, shape: shape)
        return [result]
    }

    /// Sets the seed that the random number generators of this model use.
    /// Note that the model also uses an internal seed offset which is incremented when the model is stepped.
    /// - Parameter seed: The random number generator seed.
    func setSeed(_ seed: Int) {
        baseRandomSeed = seed
    }

    private static let defaultMaxThreads: Int = 4

    /// The base value used for seeding the random number generator (the one the user has control over)
    var baseRandomSeed: Int = 0 // TODO: atomic

    /// Seed used for random number generation.
    /// Note: incremented by each std::async call used for model stepping.
    var randomSeedOffset: Int = 0 // TODO: atomic

}
