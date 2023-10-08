import Foundation

extension Bitmap {

    /// Calculates the root-mean-square error between two bitmaps.
    func differenceFull(with second: Bitmap) -> Double {
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

    /// Calculates the root-mean-square error between the parts of the two bitmaps within the scanline mask.
    /// This is for optimization purposes, it lets us calculate new error values only for parts of the image
    /// we know have changed.
    /// - Parameters:
    ///   - second: The bitmap after the change.
    ///   - target: The target bitmap.
    ///   - score: The score.
    ///   - mask: The scanlines.
    /// - Returns: The difference/error between the two bitmaps, masked by the scanlines.
    func differencePartial(
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

}
