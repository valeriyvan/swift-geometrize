import Foundation

// TODO: this should not rely on RGBAccessible
extension BitmapG where ColorType: RGBAccessible & AlphaBlendable {
    /// Computes optimal color for drawing a shape over this bitmap.
    /// This is used by the geometrize optimization algorithm.
    /// - Parameters:
    ///   - other: The target bitmap to compare against
    ///   - scanlines: The scanlines defining the shape area
    ///   - alpha: The alpha value for the shape (0-255)
    /// - Returns: Optimal color for the shape
    public func computeColor(other: BitmapG<ColorType>, scanlines: [Scanline], alpha: UInt8 /* TODO: type should be different */) -> ColorType {
        guard width == other.width, height == other.height else {
            fatalError("Mismatching bitmap sizes \(width)x\(height) vs \(other.width)x\(other.height)")
        }
        // Early out to avoid integer divide by 0
        guard !scanlines.isEmpty else {
            print("Warning: there are no scanlines.")
            return ColorType.black
        }
        guard alpha != 0 else {
            print("Warning: alpha cannot be 0.")
            return ColorType.black
        }

        var totalRed: Int64 = 0
        var totalGreen: Int64 = 0
        var totalBlue: Int64 = 0
        var count: Int64 = 0
        let a: Int64 = Int64(257.0 * 255.0 / Double(alpha))

        for line in scanlines {
            for x in line.x1...line.x2 {
                let target = self[x, line.y]
                let current = other[x, line.y]
                
                // Get RGB components
                let tr: Int64 = Int64(target.r)
                let tg: Int64 = Int64(target.g)
                let tb: Int64 = Int64(target.b)
                let cr: Int64 = Int64(current.r)
                let cg: Int64 = Int64(current.g)
                let cb: Int64 = Int64(current.b)

                // Mix the red, green and blue components, blending by the given alpha value
                totalRed += Int64((tr - cr) * a + cr * 257)
                totalGreen += Int64((tg - cg) * a + cg * 257)
                totalBlue += Int64((tb - cb) * a + cb * 257)
            }
            count += Int64(line.x2 - line.x1 + 1)
        }

        let rr: Int64 = Int64(totalRed / count) >> 8
        let gg: Int64 = Int64(totalGreen / count) >> 8
        let bb: Int64 = Int64(totalBlue / count) >> 8

        // Scale totals down to 0-255 range and return average blended color
        let r: UInt8 = UInt8(max(0, min(255, rr)))
        let g: UInt8 = UInt8(max(0, min(255, gg)))
        let b: UInt8 = UInt8(max(0, min(255, bb)))

        return ColorType(r: r, g: g, b: b).withAlpha(alpha)
    }
}

// Fallback for colors that only support RGB (no alpha)
extension BitmapG where ColorType: RGBAccessible {
    /// Computes optimal color for drawing a shape over this bitmap (RGB only version).
    /// - Parameters:
    ///   - other: The target bitmap to compare against
    ///   - scanlines: The scanlines defining the shape area
    /// - Returns: Optimal color for the shape
    public func computeColorRGB(other: BitmapG<ColorType>, scanlines: [Scanline]) -> ColorType {
        guard width == other.width, height == other.height else {
            fatalError("Mismatching bitmap sizes \(width)x\(height) vs \(other.width)x\(other.height)")
        }
        guard !scanlines.isEmpty else {
            print("Warning: there are no scanlines.")
            return ColorType.black
        }

        var totalRed: Int64 = 0
        var totalGreen: Int64 = 0
        var totalBlue: Int64 = 0
        var count: Int64 = 0

        for line in scanlines {
            for x in line.x1...line.x2 {
                let target = self[x, line.y]
                
                totalRed += Int64(target.r)
                totalGreen += Int64(target.g)
                totalBlue += Int64(target.b)
            }
            count += Int64(line.x2 - line.x1 + 1)
        }

        let r: UInt8 = UInt8(max(0, min(255, totalRed / count)))
        let g: UInt8 = UInt8(max(0, min(255, totalGreen / count)))
        let b: UInt8 = UInt8(max(0, min(255, totalBlue / count)))

        return ColorType(r: r, g: g, b: b)
    }
}
