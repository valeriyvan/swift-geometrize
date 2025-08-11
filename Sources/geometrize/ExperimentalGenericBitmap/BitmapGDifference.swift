import Foundation

extension BitmapG {

    /// Calculates the root-mean-square (RMS) error between two complete bitmaps.
    public func differenceFull(with second: BitmapG<ColorType>) -> Double {
        assert(width == second.width)
        assert(height == second.height)
        var total: Int64 = 0
        for y in 0..<height {
            for x in 0..<width {
                let f: ColorType = self[x, y]
                let s: ColorType = second[x, y]
                total += f.squaredDifference(with: s)
            }
        }
        return sqrt(Double(total) / (Double(width) * Double(height) * Double(ColorType.totalSize))) / 255.0
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
        with second: BitmapG<ColorType>,
        target: BitmapG<ColorType>,
        score: Double,
        mask lines: [Scanline]
    ) -> Double {
        let rgbaCount: UInt64 = UInt64(target.width * target.height * 4)
        var total: UInt64 = UInt64((score * 255.0) * (score * 255.0) * Double(rgbaCount))
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                let t: ColorType = target[x, y]
                let b: ColorType = self[x, y]
                let a: ColorType = second[x, y]
                total -= UInt64(t.squaredDifference(with: b))
                total += UInt64(t.squaredDifference(with: a))
            }
        }
        return sqrt(Double(total) / Double(rgbaCount)) / 255.0
    }

}
