import Foundation

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
    return current.differencePartial(with: buffer, target: target, score: score, mask: lines)
}
