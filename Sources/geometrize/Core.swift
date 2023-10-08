import Foundation

/// Calculates the color of the scanlines.
/// - Parameters:
///   - target: The target image.
///   - current: The current image.
///   - lines: The scanlines.
///   - alpha: The alpha of the scanline.
/// - Returns: The color of the scanlines.
func computeColor(
    target: Bitmap,
    current: Bitmap,
    lines: [Scanline],
    alpha: UInt8
) -> Rgba {
    // Early out to avoid integer divide by 0
    guard !lines.isEmpty else {
        print("Warning: there are no scanlines.")
        return .black
    }
    guard alpha != 0 else {
        print("Warning: alpha cannot be 0.")
        return .black
    }

    var totalRed: Int64 = 0
    var totalGreen: Int64 = 0
    var totalBlue: Int64 = 0
    var count: Int64 = 0
    let a: Int32 = Int32(257.0 * 255.0 / Double(alpha))

    for line in lines {
        let y: Int = line.y
        for x in line.x1...line.x2 {
            // Get the overlapping target and current colors
            let t: Rgba = target[x, y]
            let c: Rgba = current[x, y]

            let tr: Int32 = Int32(t.r)
            let tg: Int32 = Int32(t.g)
            let tb: Int32 = Int32(t.b)
            let cr: Int32 = Int32(c.r)
            let cg: Int32 = Int32(c.g)
            let cb: Int32 = Int32(c.b)

            // Mix the red, green and blue components, blending by the given alpha value
            totalRed += Int64((tr - cr) * a + cr * 257)
            totalGreen += Int64((tg - cg) * a + cg * 257)
            totalBlue += Int64((tb - cb) * a + cb * 257)
            count += 1
        }
    }

    let rr: Int32 = Int32(totalRed / count) >> 8
    let gg: Int32 = Int32(totalGreen / count) >> 8
    let bb: Int32 = Int32(totalBlue / count) >> 8

    // Scale totals down to 0-255 range and return average blended color
    let r: UInt8 = UInt8(rr.clamped(to: 0...255))
    let g: UInt8 = UInt8(gg.clamped(to: 0...255))
    let b: UInt8 = UInt8(bb.clamped(to: 0...255))

    return Rgba(r: r, g: g, b: b, a: alpha)
}

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
    var s: State = state.copy()
    var bestState: State = state.copy()
    var bestEnergy: Double = bestState.score
    var age: Int = 0
    while age < maxAge {
        let undo: State = s.mutate(xMin: 0, yMin: 0, xMax: target.width - 1, yMax: target.height - 1, using: &generator)
        s.score = energyFunction(
            s.shape.rasterize(xMin: 0, yMin: 0, xMax: target.width - 1, yMax: target.height - 1),
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
    let shape = shapeCreator(&generator)
    shape.setup(xMin: 0, yMin: 0, xMax: target.width, yMax: target.height, using: &generator)
    var bestState: State = State(shape: shape, alpha: alpha)
    bestState.score = energyFunction(
        bestState.shape.rasterize(xMin: 0, yMin: 0, xMax: target.width, yMax: target.height),
        bestState.alpha,
        target,
        current,
        &buffer,
        lastScore
    )
    var bestEnergy: Double = bestState.score
    for i in 0...n {
        let shape = shapeCreator(&generator)
        shape.setup(xMin: 0, yMin: 0, xMax: target.width, yMax: target.height, using: &generator)
        var state: State = State(shape: shape, alpha: alpha)
        state.score = energyFunction(
            state.shape.rasterize(xMin: 0, yMin: 0, xMax: target.width, yMax: target.height),
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
