import Foundation

/// The model class is the model for the core optimization/fitting algorithm.
class GeometrizeModelHillClimb: GeometrizeModelBase {

    // Runs concurrently maxThreads optimization sessions and returns array of optimization results.
    // step function then takes the only result with the best score.
    // Therefore it does make sense decrease shapeCount proportionally when increasing maxThreads
    // to achieve same effectiveness.
    private func getHillClimbState( // swiftlint:disable:this function_parameter_count
        shapeCreator: @escaping ShapeCreator,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: Int,
        maxThreads: Int, // Ignored. Single thread is used at the moment.
        energyFunction: @escaping EnergyFunction
    ) -> [State] {
        // Ensure that the results of the random generation are the same between tasks with identical settings
        // The RNG is thread-local and std::async may use a thread pool (which is why this is necessary)
        // Note this implementation requires maxThreads to be the same between tasks for each task to produce the same results.

        let lastScore = lastScore

        let concurrentQueue = DispatchQueue(label: "geometrize.concurrent.queue", attributes: .concurrent)
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "geometrize.serial.queue")
        var states: [State] = []

        for _ in 0..<maxThreads {
            let seed = baseRandomSeed + randomSeedOffset
            randomSeedOffset += 1
            var generator = SplitMix64(seed: UInt64(seed))
            group.enter()
            concurrentQueue.async { [targetBitmap, currentBitmap] in
                var buffer: Bitmap = currentBitmap
                bestHillClimbState(
                    shapeCreator: shapeCreator,
                    alpha: alpha,
                    n: shapeCount,
                    age: maxShapeMutations,
                    target: targetBitmap,
                    current: currentBitmap,
                    buffer: &buffer,
                    lastScore: lastScore,
                    energyFunction: energyFunction,
                    using: &generator,
                    callback: { state in
                        states.append(state)
                        group.leave()
                    },
                    queue: serialQueue
                )
            }
        }
        group.wait()

        return states
    }

    /// Concurrently runs several optimization sessions tying improving image geometrization by adding a shape to it
    /// and returns result of the best optimization or nil if improvement of image wasn't found.
    /// - Parameters:
    ///   - shapeCreator: A function that will produce the shapes.
    ///   - alpha: The alpha of the shape.
    ///   - shapeCount: The number of random shapes to generate (only 1 is chosen in the end).
    ///   - maxShapeMutations: The maximum number of times to mutate each random shape.
    ///   - maxThreads: The maximum number of threads to use during this step.
    ///   - energyFunction: A function to calculate the energy.
    ///   - addShapePrecondition: A function to determine whether to accept a shape.
    /// - Returns: Returns `ShapeResult` representing a shape added to improve image or nil if improvement wasn't found.
    func step( // swiftlint:disable:this function_parameter_count
        shapeCreator: @escaping ShapeCreator,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: Int,
        maxThreads: Int,
        energyFunction: @escaping EnergyFunction,
        addShapePrecondition: @escaping ShapeAcceptancePreconditionFunction = defaultAddShapePrecondition
    ) -> ShapeResult? {

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
        let lines: [Scanline] = shape.rasterize(x: 0...width - 1, y: 0...height - 1)
        let color: Rgba = lines.computeColor(target: targetBitmap, current: currentBitmap, alpha: alpha)
        let before: Bitmap = currentBitmap
        currentBitmap.draw(lines: lines, color: color)

        // Check for an improvement - if not, roll back and return no result
        let newScore: Double = before.differencePartial(
            with: currentBitmap,
            target: targetBitmap,
            score: lastScore,
            mask: lines
        )
        guard addShapePrecondition(lastScore, newScore, shape, lines, color, before, currentBitmap, targetBitmap) else {
            currentBitmap = before
            return nil
        }

        // Improvement - set new baseline and return the new shape
        lastScore = newScore

        return ShapeResult(score: lastScore, color: color, shape: shape)
    }

    /// Sets the seed that the random number generators of this model use.
    /// Note that the model also uses an internal seed offset which is incremented when the model is stepped.
    /// - Parameter seed: The random number generator seed.
    func setSeed(_ seed: Int) {
        baseRandomSeed = seed
    }

    private static let defaultMaxThreads: Int = 8

    /// The base value used for seeding the random number generator (the one the user has control over)
    var baseRandomSeed: Int = 0

    /// Seed used for random number generation.
    /// Note: incremented by each std::async call used for model stepping.
    var randomSeedOffset: Int = 0

}
