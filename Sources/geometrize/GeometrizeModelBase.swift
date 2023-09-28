import Foundation

/// Protocol to which models for different geometrizing algorithms should conform
class GeometrizeModelBase {

    /// Creates a model that will aim to replicate the target bitmap with shapes.
    /// - Parameter targetBitmap: The target bitmap to replicate with shapes.
    init(targetBitmap: Bitmap) {
        self.targetBitmap = targetBitmap
        currentBitmap = Bitmap(width: targetBitmap.width, height: targetBitmap.height, color: targetBitmap.averageColor())
        lastScore = differenceFull(first: targetBitmap, second: currentBitmap)
    }

    /// Creates a model that will optimize for the given target bitmap, starting from the given initial bitmap.
    /// The target bitmap and initial bitmap must be the same size (width and height).
    /// - Parameters:
    ///   - target: The target bitmap to replicate with shapes.
    ///   - initial: The starting bitmap.
    init(target: Bitmap, initial: Bitmap) {
        targetBitmap = target
        currentBitmap = initial
        lastScore = differenceFull(first: target, second: currentBitmap)
        assert(target.width == currentBitmap.width)
        assert(target.height == currentBitmap.height)
    }

    /// Resets the model back to the state it was in when it was created.
    /// - Parameter backgroundColor: The starting background color to use.
    func reset(backgroundColor: Rgba) {
       currentBitmap.fill(color: backgroundColor)
       lastScore = differenceFull(first: targetBitmap, second: currentBitmap)
   }

    var width: Int { targetBitmap.width }
    var height: Int { targetBitmap.height }

    /// Draws a shape on the model. Typically used when to manually add a shape to the image (e.g. when setting an initial background).
    /// NOTE this unconditionally draws the shape, even if it increases the difference between the source and target image.
    /// - Parameters:
    ///   - shape: The shape to draw.
    ///   - color: The color (including alpha) of the shape.
    /// - Returns: Data about the shape drawn on the model.
    func draw(shape: any Shape, color: Rgba) -> ShapeResult {
        let lines: [Scanline] = shape.rasterize()
        let before: Bitmap = currentBitmap
        currentBitmap.draw(lines: lines, color: color)
        lastScore = differencePartial(target: targetBitmap, before: before, after: currentBitmap, score: lastScore, lines: lines)
        return ShapeResult(score: lastScore, color: color, shape: shape)
    }

    /// The target bitmap, the bitmap we aim to approximate.
    internal var targetBitmap: Bitmap

    func getTarget() -> Bitmap { targetBitmap }

    /// The current bitmap.
    internal var currentBitmap: Bitmap

    /// Score derived from calculating the difference between bitmaps.
    internal var lastScore: Double

}
