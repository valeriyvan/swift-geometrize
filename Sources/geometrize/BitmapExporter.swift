import Foundation

public struct BitmapExporter {

    public init() {}

    /// Exports shape data as a bitmap.
    /// - Parameters:
    ///   - data: The shape data to export.
    ///   - width: The width of the bitmap (downscaled).
    ///   - height: The height of the bitmap (downscaled).
    ///   - originalWidth: The original width of the image (before downscaling).
    ///   - originalHeight: The original height of the image (before downscaling).
    /// - Returns: A bitmap reconstructed from the shape data.
    public func export(
        data: [ShapeResult],
        width: Int,
        height: Int,
        originalWidth: Int? = nil,
        originalHeight: Int? = nil
    ) -> Bitmap {
        // Determine if we should output at original size or downscaled size
        let outputWidth = originalWidth ?? width
        let outputHeight = originalHeight ?? height

        // Create bitmap with the right dimensions
        var bitmap = Bitmap(width: outputWidth, height: outputHeight, color: .white)

        // If the original dimensions match the processed dimensions, no scaling needed
        if outputWidth == width && outputHeight == height {
            for shapeResult in data {
                let lines = shapeResult.shape.rasterize(x: 0...width-1, y: 0...height-1)
                bitmap.draw(lines: lines, color: shapeResult.color)
            }
            return bitmap
        }

        // We need to create a scaled version of the result
        // The easiest approach is to create a bitmap at the processed size, then scale it

        // Step 1: Create a bitmap at the processed size and draw all shapes on it
        var processedBitmap = Bitmap(width: width, height: height, color: .white)
        for shapeResult in data {
            let lines = shapeResult.shape.rasterize(x: 0...width-1, y: 0...height-1)
            processedBitmap.draw(lines: lines, color: shapeResult.color)
        }

        // Step 2: Scale the bitmap to the original dimensions
        // We'll use a nearest-neighbor approach as a simple scaling algorithm
        let reciprocalScaleFactorX = Double(width) / Double(outputWidth)
        let reciprocalScaleFactorY = Double(height) / Double(outputHeight)

        for y in 0..<outputHeight {
            for x in 0..<outputWidth {
                // Map from original space to processed space using multiplication (faster than division)
                let srcX = Int(Double(x) * reciprocalScaleFactorX).clamped(to: 0...width-1)
                let srcY = Int(Double(y) * reciprocalScaleFactorY).clamped(to: 0...height-1)
                // Copy the pixel
                bitmap[x, y] = processedBitmap[srcX, srcY]
            }
        }

        return bitmap
    }
}
