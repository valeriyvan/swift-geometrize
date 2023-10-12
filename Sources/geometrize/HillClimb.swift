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
///   - using: The Random number generator to use.
///   - callback: The closure to call with resulting state.
///   - queue: The queue to call callback
/// - Returns: The best state acquired from hill climbing i.e. the one with the lowest energy.
func bestHillClimbState( // swiftlint:disable:this function_parameter_count
    shapeCreator: ShapeCreator,
    alpha: UInt8,
    n: Int,
    age: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction = defaultEnergyFunction,
    using generator: inout SplitMix64,
    callback: @escaping (State) -> Void,
    queue: DispatchQueue
) {
    let state: State = bestRandomState(
        shapeCreator: shapeCreator,
        alpha: alpha,
        n: n,
        target: target,
        current: current,
        buffer: &buffer,
        lastScore: lastScore,
        energyFunction: energyFunction,
        using: &generator
    )
    let resState = hillClimb(
        state: state,
        maxAge: age,
        target: target,
        current: current,
        buffer: &buffer,
        lastScore: lastScore,
        energyFunction: energyFunction,
        using: &generator
    )
    queue.async {
        callback(resState)
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
func hillClimb( // swiftlint:disable:this function_parameter_count
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
    var s: State = state.copy()
    var bestState: State = state.copy()
    var bestEnergy: Double = bestState.score
    var age: Int = 0
    while age < maxAge {
        let undo: State = s.mutate(x: xRange, y: yRange, using: &generator)
        s.score = energyFunction(
            s.shape.rasterize(x: xRange, y: yRange),
            s.alpha,
            target,
            current,
            &buffer,
            lastScore
        )
        let energy: Double = s.score
        if energy >= bestEnergy {
            s = undo.copy()
        } else {
            bestEnergy = energy
            bestState = s.copy()
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
private func bestRandomState( // swiftlint:disable:this function_parameter_count
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
    let shape = shapeCreator(&generator)
    shape.setup(x: xRange, y: yRange, using: &generator)
    var bestState: State = State(shape: shape, alpha: alpha)
    bestState.score = energyFunction(
        bestState.shape.rasterize(x: xRange, y: yRange),
        bestState.alpha,
        target,
        current,
        &buffer,
        lastScore
    )
    var bestEnergy: Double = bestState.score
    for i in 0...n {
        let shape = shapeCreator(&generator)
        shape.setup(x: xRange, y: yRange, using: &generator)
        var state: State = State(shape: shape, alpha: alpha)
        state.score = energyFunction(
            state.shape.rasterize(x: xRange, y: yRange),
            state.alpha,
            target,
            current,
            &buffer,
            lastScore
        )
        let energy: Double = state.score
        if i == 0 || energy < bestEnergy {
            bestEnergy = energy
            bestState = state.copy()
        }
    }
    return bestState.copy() // TODO: is copy needed here???
}
