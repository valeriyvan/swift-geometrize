import Foundation

// The core functions for Geometrize.

// Type alias for a function that calculates a measure of the improvement adding the scanlines of a shape provides - lower energy is better.
// @param lines The scanlines of the shape.
// @param alpha The alpha of the scanlines.
// @param target The target bitmap.
// @param current The current bitmap.
// @param buffer The buffer bitmap.
// @param score The score.
// @return The energy measure.

typealias EnergyFunction = (
    _ lines: [Scanline],
    _ alpha: UInt, // TODO: why not UInt8???
    _ target: Bitmap,
    _ curent: Bitmap,
    _ buffer: inout Bitmap,
    _ score: Double
) -> Double

// The default/built-in energy function that calculates a measure of the improvement adding
// the scanlines of a shape provides - lower energy is better.
// @param lines The scanlines of the shape.
// @param alpha The alpha of the scanlines.
// @param target The target bitmap.
// @param current The current bitmap.
// @param buffer The buffer bitmap.
// @param score The score.
// @return The energy measure.
func defaultEnergyFunction(
    _ lines: [Scanline],
    _ alpha: UInt, // TODO: why not UInt8???
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

 // Calculates the color of the scanlines.
 // @param target The target image.
 // @param current The current image.
 // @param lines The scanlines.
 // @param alpha The alpha of the scanline.
 // @return The color of the scanlines.
func computeColor(
    target: Bitmap,
    current: Bitmap,
    lines: [Scanline],
    alpha: UInt8
) -> Rgba {
    // Early out to avoid integer divide by 0
    guard !lines.isEmpty else {
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

// Calculates the root-mean-square error between two bitmaps.
// @param first The first bitmap.
// @param second The second bitmap.
// @return The difference/error measure between the two bitmaps.
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

// Calculates the root-mean-square error between the parts of the two bitmaps within the scanline mask.
// This is for optimization purposes, it lets us calculate new error values only for parts of the image
// we know have changed.
// @param target The target bitmap.
// @param before The bitmap before the change.
// @param after The bitmap after the change.
// @param score The score.
// @param lines The scanlines.
// @return The difference/error between the two bitmaps, masked by the scanlines.

func differencePartial(
    target: Bitmap,
    before: Bitmap,
    after: Bitmap,
    score: Double,
    lines: [Scanline]
) -> Double {
    let rgbaCount: UInt64 = UInt64(target.width * target.height * 4)
    var total: UInt64 = UInt64(score * 255.0) * UInt64(score * 255.0) * rgbaCount
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

// Gets the best state using a hill climbing algorithm.
// @param shapeCreator A function that will create the shapes that will be chosen from.
// @param alpha The opacity of the shape.
// @param n The number of random states to generate.
// @param age The number of hillclimbing steps.
// @param target The target bitmap.
// @param current The current bitmap.
// @param buffer The buffer bitmap.
// @param lastScore The last score.
// @param customEnergyFunction An optional function to calculate the energy (if unspecified a default implementation is used).
// @return The best state acquired from hill climbing i.e. the one with the lowest energy.
func bestHillClimbState(
    shapeCreator: () -> Shape,
    alpha: UInt,
    n: UInt,
    age: UInt,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    customEnergyFunction: EnergyFunction? = nil
) -> State {
    let energyFunction = customEnergyFunction ?? defaultEnergyFunction
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

// Hill climbing optimization algorithm, attempts to minimize energy (the error/difference).
// @param state The state to optimize.
// @param maxAge The maximum age.
// @param target The target bitmap.
// @param current The current bitmap.
// @param buffer The buffer bitmap.
// @param lastScore The last score.
// @return The best state found from hillclimbing.
fileprivate func hillClimb(
    state: State,
    maxAge: UInt,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction
) -> State {
    var s: State = state
    var bestState: State = state
    var bestEnergy: Double = bestState.m_score
    var age: UInt = 0
    while age < maxAge {
        let undo: State = s.mutate()
        s.m_score = energyFunction(s.m_shape.rasterize(), UInt(s.m_alpha), target, current, &buffer, lastScore)
        let energy: Double = s.m_score
        if energy >= bestEnergy {
            s = undo
        } else {
            bestEnergy = energy
            bestState = s
            age = UInt.max // TODO: What's the point??? And following increment overflows
        }
        age += 1
    }
    return bestState
}

// @brief bestRandomState Gets the best state using a random algorithm.
// @param shapeCreator A function that will create the shapes that will be chosen from.
// @param alpha The opacity of the shape.
// @param n The number of states to try.
// @param target The target bitmap.
// @param current The current bitmap.
// @param buffer The buffer bitmap.
// @param lastScore The last score.
// @return The best random state i.e. the one with the lowest energy.
fileprivate func bestRandomState(
    shapeCreator: () -> Shape,
    alpha: UInt,
    n: UInt,
    target: Bitmap,
    current: Bitmap,
    buffer: inout Bitmap,
    lastScore: Double,
    energyFunction: EnergyFunction
) -> State {
    var bestState: State = State(m_score: 0, m_alpha: UInt8(alpha), m_shape: shapeCreator()) // TODO: geometrize::State bestState(shapeCreator(), alpha);
    bestState.m_score = energyFunction(bestState.m_shape.rasterize(), UInt(bestState.m_alpha), target, current, &buffer, lastScore)
    var bestEnergy: Double = bestState.m_score
    for i in 0...n {
        var state: State = State(m_score: 0, m_alpha: UInt8(alpha), m_shape: shapeCreator()) // TODO: geometrize::State state(shapeCreator(), alpha);
        state.m_score = energyFunction(state.m_shape.rasterize(), UInt(state.m_alpha), target, current, &buffer, lastScore)
        let energy: Double = state.m_score
        if i == 0 || energy < bestEnergy {
            bestEnergy = energy
            bestState = state
        }
    }
    return bestState;
}
