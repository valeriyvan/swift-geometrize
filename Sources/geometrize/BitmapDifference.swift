import Foundation

extension Bitmap {

    /// Calculates the root-mean-square error between two bitmaps.
    public func differenceFull(with second: Bitmap) -> Double {
        assert(width == second.width)
        assert(height == second.height)

        var total: Int64 = 0

        for y in 0..<height {
            for x in 0..<width {
                let f: Rgba = self[x, y]
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

    // This variant is less then 5% faster.
    public func differenceFullExperimental(with second: Bitmap) -> Double {
        assert(width == second.width)
        assert(height == second.height)
        var total: Int64 = 0
        for y in 0..<height {
            for x in 0..<width {
                let f = self.rgbaAsSIMD4Int32(x: x, y: y)
                let s = second.rgbaAsSIMD4Int32(x: x, y: y)
                let d = f &- s
                total += Int64((d &* d).wrappedSum())
            }
        }
        return sqrt(Double(total) / (Double(width) * Double(height) * 4.0)) / 255.0
    }

    /// Calculates the root-mean-square error between the parts of the two bitmaps within the scanline mask.
    /// This is for optimization purposes, it lets calculate new error values only for parts of the image
    /// known to be changed.
    /// - Parameters:
    ///   - second: The bitmap after the change.
    ///   - target: The target bitmap.
    ///   - score: The score.
    ///   - mask: The scanlines.
    /// - Returns: The difference/error between the two bitmaps, masked by the scanlines.
    ///
    /// Doesn't take into consideration human color perception.
    /// Look https://en.wikipedia.org/wiki/Color_difference
    public func differencePartial(
        with second: Bitmap,
        target: Bitmap,
        score: Double,
        mask lines: [Scanline]
    ) -> Double {
        let rgbaCount: UInt64 = UInt64(target.width * target.height * 4)
        var total: UInt64 = UInt64((score * 255.0) * (score * 255.0) * Double(rgbaCount))
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                let t: Rgba = target[x, y]
                let b: Rgba = self[x, y]
                let a: Rgba = second[x, y]
                total -= UInt64(t.squaredDifference(with: b))
                total += UInt64(t.squaredDifference(with: a))
            }
        }

        return sqrt(Double(total) / Double(rgbaCount)) / 255.0
    }

    // This variant is less then 5% faster.
    public func differencePartialExperimental(
        with second: Bitmap,
        target: Bitmap,
        score: Double,
        mask lines: [Scanline]
    ) -> Double {
        let rgbaCount: UInt64 = UInt64(target.width * target.height * 4)
        var total: UInt64 = UInt64((score * 255.0) * (score * 255.0) * Double(rgbaCount))
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                let t = target.rgbaAsSIMD4Int32(x: x, y: y)
                let b = self.rgbaAsSIMD4Int32(x: x, y: y)
                let a = second.rgbaAsSIMD4Int32(x: x, y: y)
                let dtb: SIMD4<Int32> = t &- b
                let dta: SIMD4<Int32> = t &- a
                total -= UInt64((dtb &* dtb).wrappedSum())
                total += UInt64((dta &* dta).wrappedSum())
            }
        }
        return sqrt(Double(total) / Double(rgbaCount)) / 255.0
    }

}
