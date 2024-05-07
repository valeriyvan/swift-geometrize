import Foundation

public struct BitmapExporter {

    public init() {}

    /// Exports shape data as a complete SVG image.
    /// - Parameters:
    ///   - data The shape data to export.
    ///   - width The width of the SVG image.
    ///   - height The height of the SVG image.
    /// - Returns: A string representing the SVG image.
    public func export(
        data: [ShapeResult],
        width: Int,
        height: Int
    ) -> Bitmap {
        var bitmap = Bitmap(width: width, height: height, color: .white)
        for shapeResult in data {
            let lines = shapeResult.shape.rasterize(x: 0...width-1, y: 0...height-1)
            bitmap.draw(lines: lines, color: shapeResult.color)
        }
        return bitmap
    }

}
