import Foundation

/// Represents a scanline, a row of pixels running across a bitmap.
public struct Scanline {

    /// Creates empty useless scanline.
    internal init() {
        y = 0
        x1 = 0
        x2 = 0
    }

    /// Creates a new scanline.
    /// - Parameters:
    ///   - y: The y-coordinate.
    ///   - x1: The leftmost x-coordinate.
    ///   - x2: The rightmost x-coordinate.
    internal init(y: Int, x1: Int, x2: Int) {
        self.y = y
        self.x1 = x1
        self.x2 = x2
        if x1 > x2 {
            print("Warning: Scanline has x1(\(x1)) > x2(\(x2). This makes scanline invisible.")
        }
    }

    /// The y-coordinate of the scanline.
    internal let y: Int

    /// The leftmost x-coordinate of the scanline.
    internal let x1: Int

    /// The rightmost x-coordinate of the scanline.
    internal let x2: Int

    /// Returned nil means trimming eliminates scanline completely.

    func trimmed(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> Self? {
        guard yRange ~= y && x2 >= x1 else { return nil }
        let x1 = x1.clamped(to: xRange)
        let x2 = x2.clamped(to: xRange)
        return Scanline(y: y, x1: x1, x2: x2)
    }

}

extension Scanline: Equatable {}

extension Scanline: CustomStringConvertible {

    public var description: String {
        "Scanline(y: \(y), x1: \(x1), x2: \(x2))"
    }

}

extension Scanline: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        let scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines
        guard
            scanner.scanString("Scanline(") != nil,
            scanner.scanString("y:") != nil,
            let y = scanner.scanInt(),
            scanner.scanString(",") != nil,
            scanner.scanString("x1:") != nil,
            let x1 = scanner.scanInt(),
            scanner.scanString(",") != nil,
            scanner.scanString("x2:") != nil,
            let x2 = scanner.scanInt(),
            scanner.scanString(")") != nil
        else {
            fatalError("Incorrect format of Scanline: \(value)")
        }
        self.y = y
        self.x1 = x1
        self.x2 = x2
    }
}

extension Array where Element == Scanline {

    /// Crops the scanning width of an array of scanlines so they do not scan outside of the given area.
    /// - Parameters:
    ///   - minX: The minimum x value to crop to.
    ///   - minY: The minimum y value to crop to.
    ///   - maxX: The maximum x value to crop to.
    ///   - maxY: The maximum y value to crop to.
    /// - Returns: A new vector of cropped scanlines.
    func trimmed(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> Self {
        var trimmedScanlines = Self()
        for line in self {
            guard yRange ~= line.y && line.x2 >= line.x1 else { continue }
            let x1 = line.x1.clamped(to: xRange)
            let x2 = line.x2.clamped(to: xRange)
            trimmedScanlines.append(Scanline(y: line.y, x1: x1, x2: x2))
        }
        return trimmedScanlines
    }

    /// Calculates the color of the scanlines.
    /// - Parameters:
    ///   - target: The target image.
    ///   - current: The current image.
    ///   - alpha: The alpha of the scanline.
    /// - Returns: The color of the scanlines.
    @inlinable
    @inline(__always)
    func computeColor(
        target: Bitmap,
        current: Bitmap,
        alpha: UInt8
    ) -> Rgba {
        target.computeColor(other: current, scanlines: self, alpha: alpha)
    }

}
