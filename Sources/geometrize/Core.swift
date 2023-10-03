import Foundation

// The core functions for Geometrize.

/// Type alias for a function that calculates a measure of the improvement adding
/// the scanlines of a shape provides - lower energy is better.
/// - Parameters:
///   - lines The scanlines of the shape.
///   - alpha The alpha of the scanlines.
///   - target The target bitmap.
///   - current The current bitmap.
///   - buffer The buffer bitmap.
///   - score The score.
/// - Returns: The energy measure.
public typealias EnergyFunction = (
    _ lines: [Scanline],
    _ alpha: UInt8,
    _ target: Bitmap,
    _ curent: Bitmap,
    _ buffer: inout Bitmap,
    _ score: Double
) -> Double

/// The default/built-in energy function that calculates a measure of the improvement adding
/// the scanlines of a shape provides - lower energy is better.
/// - Parameters:
///   - lines: The scanlines of the shape.
///   - alpha:  The alpha of the scanlines.
///   - target: The target bitmap.
///   - current: The current bitmap.
///   - buffer: The buffer bitmap.
///   - score: The score.
/// - Returns: The energy measure.
public func defaultEnergyFunction( // swiftlint:disable:this function_parameter_count
    _ lines: [Scanline],
    _ alpha: UInt8,
    _ target: Bitmap,
    _ current: Bitmap,
    _ buffer: inout Bitmap,
    _ score: Double
) -> Double {
    // Calculate best color for areas covered by the scanlines
    let color: Rgba = computeColor(target: target, current: current, lines: lines, alpha: UInt8(alpha))
    // Copy area covered by scanlines to buffer bitmap
    buffer.copy(lines: lines, source: current)
    // Blend scanlines into the buffer using the color calculated earlier
    buffer.draw(lines: lines, color: color)
    // Get error measure between areas of current and modified buffers covered by scanlines
    return differencePartial(target: target, before: current, after: buffer, score: score, lines: lines)
}

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

/// Calculates the root-mean-square error between two bitmaps.
/// - Parameters:
///   - first: The first bitmap.
///   - second: The second bitmap.
/// - Returns: The difference/error measure between the two bitmaps.
func differenceFull(first: Bitmap, second: Bitmap) -> Double {
    assert(first.width == second.width)
    assert(first.height == second.height)

    let width = first.width
    let height = first.height
    var total: Int64 = 0

    for y in 0..<height {
        for x in 0..<width {
            let f: Rgba = first[x, y]
            let s: Rgba = second[x, y]

            let dr: Int32 = Int32(f.r) - Int32(s.r)
            let dg: Int32 = Int32(f.g) - Int32(s.g)
            let db: Int32 = Int32(f.b) - Int32(s.b)
            let da: Int32 = Int32(f.a) - Int32(s.a)
            total += Int64(dr * dr + dg * dg + db * db + da * da)
        }
    }

    return sqrt(Double(total) / (Double(width) * Double(height) * 4.0)) / 255.0
}

/// Calculates the root-mean-square error between the parts of the two bitmaps within the scanline mask.
/// This is for optimization purposes, it lets us calculate new error values only for parts of the image
/// we know have changed.
/// - Parameters:
///   - target: The target bitmap.
///   - before: The bitmap before the change.
///   - after: The bitmap after the change.
///   - score: The score.
///   - lines: The scanlines.
/// - Returns: The difference/error between the two bitmaps, masked by the scanlines.
func differencePartial(
    target: Bitmap,
    before: Bitmap,
    after: Bitmap,
    score: Double,
    lines: [Scanline]
) -> Double {
    let rgbaCount: UInt64 = UInt64(target.width * target.height * 4)
    var total: UInt64 = UInt64((score * 255.0) * (score * 255.0) * Double(rgbaCount))
    for line in lines {
        let y = line.y
        for x in line.x1...line.x2 {
            let t: Rgba = target[x, y]
            let b: Rgba = before[x, y]
            let a: Rgba = after[x, y]

            let dtbr: Int32 = Int32(t.r) - Int32(b.r)
            let dtbg: Int32 = Int32(t.g) - Int32(b.g)
            let dtbb: Int32 = Int32(t.b) - Int32(b.b)
            let dtba: Int32 = Int32(t.a) - Int32(b.a)

            let dtar: Int32 = Int32(t.r) - Int32(a.r)
            let dtag: Int32 = Int32(t.g) - Int32(a.g)
            let dtab: Int32 = Int32(t.b) - Int32(a.b)
            let dtaa: Int32 = Int32(t.a) - Int32(a.a)

            total -= UInt64(dtbr * dtbr + dtbg * dtbg + dtbb * dtbb + dtba * dtba)
            total += UInt64(dtar * dtar + dtag * dtag + dtab * dtab + dtaa * dtaa)
        }
    }

    return sqrt(Double(total) / Double(rgbaCount)) / 255.0
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
/// - Returns: The best state acquired from hill climbing i.e. the one with the lowest energy.
func bestHillClimbState( // swiftlint:disable:this function_parameter_count
    shapeCreator: () -> any Shape,
    alpha: UInt8,
    n: Int,
    age: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction = defaultEnergyFunction
) -> State {
    let state: State = bestRandomState(
        shapeCreator: shapeCreator,
        alpha: alpha,
        n: n,
        target: target,
        current: current,
        buffer: &buffer,
        lastScore: lastScore,
        energyFunction: energyFunction
    )
    return hillClimb(
        state: state,
        maxAge: age,
        target: target,
        current: current,
        buffer: &buffer,
        lastScore: lastScore,
        energyFunction: energyFunction
    )
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
/// - Returns: The best state found from hillclimbing.
func hillClimb( // swiftlint:disable:this function_parameter_count
    state: State,
    maxAge: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction
) -> State {
    var s: State = state.copy()
    var bestState: State = state.copy()
    var bestEnergy: Double = bestState.score
    var age: Int = 0
    while age < maxAge {
        let undo: State = s.mutate()
        s.score = energyFunction(s.shape.rasterize(), s.alpha, target, current, &buffer, lastScore)
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
/// - Returns: The best random state i.e. the one with the lowest energy.
private func bestRandomState( // swiftlint:disable:this function_parameter_count
    shapeCreator: () -> any Shape,
    alpha: UInt8,
    n: Int,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction
) -> State {
    var bestState: State = State(shape: shapeCreator(), alpha: alpha)
    bestState.score = energyFunction(bestState.shape.rasterize(), bestState.alpha, target, current, &buffer, lastScore)
    var bestEnergy: Double = bestState.score
    for i in 0...n {
        var state: State = State(shape: shapeCreator(), alpha: alpha)
        state.score = energyFunction(state.shape.rasterize(), state.alpha, target, current, &buffer, lastScore)
        let energy: Double = state.score
        if i == 0 || energy < bestEnergy {
            bestEnergy = energy
            bestState = state.copy()
        }
    }
    return bestState.copy() // TODO: is copy needed here???
}
