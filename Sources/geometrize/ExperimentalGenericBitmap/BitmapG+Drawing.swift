import Foundation

extension BitmapG {
    /// Draws scanlines onto the bitmap with the specified color.
    /// - Parameters:
    ///   - lines: The scanlines to draw
    ///   - color: The color to draw with
    public mutating func draw(lines: [Scanline], color: ColorType) {
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                if isInBounds(x: x, y: y) {
                    self[x, y] = color
                }
            }
        }
    }
    
    /// Copies source pixels defined by a set of scanlines.
    /// - Parameters:
    ///   - lines: The scanlines that comprise the source to destination copying mask
    ///   - source: The source bitmap to copy the lines from
    public mutating func copy(lines: [Scanline], source: BitmapG<ColorType>) {
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                if isInBounds(x: x, y: y) && source.isInBounds(x: x, y: y) {
                    self[x, y] = source[x, y]
                }
            }
        }
    }
}

// Alpha blending support for colors that support it
extension BitmapG where ColorType: AlphaBlendable {
    /// Draws scanlines with alpha blending support.
    /// Uses the same algorithm as the original Bitmap implementation.
    /// - Parameters:
    ///   - lines: The scanlines to draw
    ///   - color: The color to draw with (supports alpha)
    public mutating func drawWithAlphaBlending(lines: [Scanline], color: ColorType) {
        // For colors without meaningful alpha (alpha = 255), fall back to simple draw
        guard color.alpha != 255 else {
            draw(lines: lines, color: color)
            return
        }
        
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                if isInBounds(x: x, y: y) {
                    let background = self[x, y]
                    self[x, y] = color.alphaComposite(over: background)
                }
            }
        }
    }
}