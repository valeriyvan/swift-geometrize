import Foundation

/// Gets the best state using a hill climbing algorithm.
/// - Parameters:
///   - shapeCreator: A function that will create the shapes that will be chosen from.
///   - alpha: The opacity of the shape.
///   - n: The number of random states to generate.
///   - age: The number of hillclimbing steps.
///   - target: The target bitmap.
///   - current: The current bitmap.
///   - buffer: The buffer bitmap.
///   - lastScore: The last score.
///   - energyFunction: A function to calculate the energy.
///   - seed: The Random number generator to use.
/// - Returns: The best state acquired from hill climbing i.e. the one with the lowest energy.
func bestHillClimbStateAsync( // swiftlint:disable:this function_parameter_count
    shapeCreator: ShapeCreator,
    alpha: UInt8,
    n: Int,
    age: Int,
    target: Bitmap,
    current: Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction = defaultEnergyFunction,
    seed: UInt64
) async -> State {
    var buffer = current
    var generator = SplitMix64(seed: seed)
    return await withCheckedContinuation { continuation in
        let state: State = bestRandomState(
            shapeCreator: shapeCreator,
            alpha: alpha,
            n: n,
            target: target,
            current: current,
            buffer: &buffer, // TODO: should it be inout?
            lastScore: lastScore,
            energyFunction: energyFunction,
            using: &generator
        )
        let resState = hillClimb(
            state: state,
            maxAge: age,
            target: target,
            current: current,
            buffer: &buffer, // TODO: should it be inout?
            lastScore: lastScore,
            energyFunction: energyFunction,
            using: &generator
        )
        continuation.resume(returning: resState)
    }
}

/// Hill climbing optimization algorithm, attempts to minimize energy (the error/difference).
/// https://en.wikipedia.org/wiki/Hill_climbing
/// - Parameters:
///   - state: The state to optimize.
///   - maxAge: The maximum age.
///   - target: The target bitmap.
///   - current: The current bitmap.
///   - buffer: The buffer bitmap.
///   - lastScore: The last score.
///   - energyFunction: An energy function to be used.
///   - using: The Random number generator to use.
/// - Returns: The best state found from hillclimbing.
func hillClimbAsync( // swiftlint:disable:this function_parameter_count
    state: State,
    maxAge: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction,
    using generator: inout SplitMix64
) -> State {
    let xRange = 0...target.width - 1, yRange = 0...target.height - 1
    var s: State = state
    var bestState: State = state
    var bestEnergy: Double = bestState.score
    var age: Int = 0
    while age < maxAge {
        let undo = s
        let alpha = s.alpha
        s = s.mutate(x: xRange, y: yRange, using: &generator) { aShape in
            return energyFunction(
                aShape.rasterize(x: xRange, y: yRange),
                alpha,
                target,
                current,
                &buffer,
                lastScore
            )
        }
        if s.score >= bestEnergy {
            s = undo
        } else {
            bestEnergy = s.score
            bestState = s
            age = Int.max // TODO: What's the point??? And following increment overflows.
        }
        if age == Int.max {
            age = 0
        } else {
            age += 1
        }
    }
    return bestState
}

/// Gets the best state using a random algorithm.
/// - Parameters:
///   - shapeCreator: A function that will create the shapes that will be chosen from.
///   - alpha: The opacity of the shape.
///   - n: The number of states to try.
///   - target: The target bitmap.
///   - current: The current bitmap.
///   - buffer: The buffer bitmap.
///   - lastScore: The last score.
///   - energyFunction: An energy function to be used.
///   - using: The Random number generator to use.
/// - Returns: The best random state i.e. the one with the lowest energy.
private func bestRandomStateAsync( // swiftlint:disable:this function_parameter_count
    shapeCreator: ShapeCreator,
    alpha: UInt8,
    n: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction,
    using generator: inout SplitMix64
) -> State {
    let xRange = 0...target.width - 1, yRange = 0...target.height - 1
    let shape = shapeCreator(&generator).setup(x: xRange, y: yRange, using: &generator)
    var bestEnergy: Double = energyFunction(
        shape.rasterize(x: xRange, y: yRange),
        alpha,
        target,
        current,
        &buffer,
        lastScore
    )
    var bestState: State = State(score: bestEnergy, alpha: alpha, shape: shape)
    for i in 0...n {
        let shape = shapeCreator(&generator).setup(x: xRange, y: yRange, using: &generator)
        let energy: Double = energyFunction(
            shape.rasterize(x: xRange, y: yRange),
            alpha,
            target,
            current,
            &buffer,
            lastScore
        )
        let state: State = State(score: energy, alpha: alpha, shape: shape)
        if i == 0 || energy < bestEnergy {
            bestEnergy = energy
            bestState = state
        }
    }
    return bestState
}
