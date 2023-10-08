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
            print("Warning: Scanline has x1(\(x1)) > x2(\(x2). This makes scanline invisible..")
        }
    }

    /// The y-coordinate of the scanline.
    internal let y: Int

    /// The leftmost x-coordinate of the scanline.
    internal let x1: Int

    /// The rightmost x-coordinate of the scanline.
    internal let x2: Int

    /// Returned nil means trimming eliminates scanline completely.
    func trimmed(minX: Int, minY: Int, maxX: Int, maxY: Int) -> Self? {
        guard minY...maxY ~= y && x2 >= x1 else { return nil }
        let xRange = minX...maxX
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
            fatalError()
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
    func trimmed(minX: Int, minY: Int, maxX: Int, maxY: Int) -> Self {
        var trimmedScanlines = Self()
        let xRange = minX...maxX
        let yRange = minY...maxY
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
    func computeColor(
        target: Bitmap,
        current: Bitmap,
        alpha: UInt8
    ) -> Rgba {
        // Early out to avoid integer divide by 0
        guard !isEmpty else {
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

        for line in self {
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

}
