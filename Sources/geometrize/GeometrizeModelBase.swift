import Foundation

/// Base class for models for geometrizing algorithms
class GeometrizeModelBase {

    /// Creates a model that will aim to replicate the target bitmap with shapes.
    /// - Parameter targetBitmap: The target bitmap to replicate with shapes.
    init(targetBitmap: Bitmap) {
        self.targetBitmap = targetBitmap
        currentBitmap = Bitmap(width: targetBitmap.width, height: targetBitmap.height, color: targetBitmap.averageColor())
        lastScore = targetBitmap.differenceFull(with: currentBitmap)
    }

    /// Creates a model that will optimize for the given target bitmap, starting from the given initial bitmap.
    /// The target bitmap and initial bitmap must be the same size (width and height).
    /// - Parameters:
    ///   - target: The target bitmap to replicate with shapes.
    ///   - initial: The starting bitmap.
    init(target: Bitmap, initial: Bitmap) {
        targetBitmap = target
        currentBitmap = initial
        lastScore = target.differenceFull(with: currentBitmap)
        assert(target.width == currentBitmap.width)
        assert(target.height == currentBitmap.height)
    }

    /// Resets the model back to the state it was in when it was created.
    /// - Parameter backgroundColor: The starting background color to use.
    func reset(backgroundColor: Rgba) {
       currentBitmap.fill(color: backgroundColor)
        lastScore = targetBitmap.differenceFull(with: currentBitmap)
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
        let lines: [Scanline] = shape.rasterize(x: 0...width - 1, y: 0...height - 1)
        let before: Bitmap = currentBitmap
        currentBitmap.draw(lines: lines, color: color)
        lastScore = before.differencePartial(with: currentBitmap, target: targetBitmap, score: lastScore, mask: lines)
        return ShapeResult(score: lastScore, color: color, shape: shape)
    }

    /// The target bitmap, the bitmap we aim to approximate.
    internal var targetBitmap: Bitmap

    /// The current bitmap.
    internal var currentBitmap: Bitmap

    /// Score derived from calculating the difference between bitmaps.
    internal var lastScore: Double

}
