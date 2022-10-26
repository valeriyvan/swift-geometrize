import Foundation

public struct SVGExporter {

    public init() {}

    /// A hook that an SVG exporter should use to augment shape styling produced by the getSvgShapeData method.
    private let svg_style_hook = "::svg_style_hook::" // swiftlint:disable:this identifier_name

    public enum RotatedEllipseSVGExportMode {
        /// Export as a translated, rotated and scaled svg <ellipse>. OpenFL's SVG library can't handle this
        case ellipseItem
        /// Export as a <polygon>, OpenFL's SVG library can handle this, but it looks quite ugly
        case polygon
    }

    /// Represents the options that can be set for the SVG
    public struct ExportOptions {
        /// Technique to use when exporting rotated ellipses
        let rotatedEllipseExportMode: RotatedEllipseSVGExportMode
        /// Id to tag the exported SVG shapes with
        var itemId: Int
        public init(rotatedEllipseExportMode: RotatedEllipseSVGExportMode = .ellipseItem, itemId: Int = 0) {
            self.rotatedEllipseExportMode = rotatedEllipseExportMode
            self.itemId = itemId
        }
    }

    /// Gets the SVG data for a single shape. This is just the <rect>/<path> etc block for the shape itself,
    /// not a complete SVG image.
    /// - Parameters:
    ///   - color: The color of the shape
    ///   - shape: The shape to convert to SVG data
    ///   - options: additional options used by the exporter
    /// - Returns: The SVG shape data for the given shape
    func singleShapeData(color: Rgba, shape: any Shape, options: ExportOptions = ExportOptions()) -> String {
        var shapeData: String = shapeData(shape: shape, options: options)
        let shapeType = shape.type()

        var styles: String = "id=\"\(options.itemId)\" "

        if [ShapeType.line, ShapeType.polyline, ShapeType.quadraticBezier].contains(shapeType) {
            styles += strokeAttrib(color: color)
            styles += " stroke-width=\"1\" fill=\"none\" "
            styles += strokeOpacityAttrib(color: color)
        } else {
            styles += fillAttrib(color: color)
            styles += " "
            styles += fillOpacityAttrib(color: color)
        }

        shapeData = shapeData.replacingOccurrences(of: svg_style_hook, with: styles)

        shapeData += "\n"

        return shapeData
    }

    /// Exports a single shape as a complete SVG image.
    /// - Parameters:
    ///   - color: The color of the shape to export.
    ///   - shape: The shape to export.
    ///   - width: The width of the SVG image.
    ///   - height: The height of the SVG image.
    ///   - options: Additional options used by the exporter.
    /// - Returns: A string representing the SVG image.
    func exportSingleShape(
        color: Rgba,
        shape: any Shape,
        width: Int,
        height: Int,
        options: ExportOptions = ExportOptions()
    ) -> String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" xmlns="http://www.w3.org/2000/svg" width=\"\(width)\" height=\"\(height)\" viewBox=\"0 0 \(width) \(height)\">
        \(singleShapeData(color: color, shape: shape, options: options))
        </svg>
        """
    }

    /// Exports shape data as a complete SVG image.
    /// - Parameters:
    ///   - data The shape data to export.
    ///   - width The width of the SVG image.
    ///   - height The height of the SVG image.
    ///   - options additional options used by the exporter.
    /// - Returns: A string representing the SVG image.
    public func export(
        data: [ShapeResult],
        width: Int,
        height: Int,
        options: ExportOptions = ExportOptions()
    ) -> String {
        var str = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" xmlns="http://www.w3.org/2000/svg" width=\"\(width)\" height=\"\(height)\" viewBox=\"0 0 \(width) \(height)\">\n
        """
        var options = options
        for (number, shapeResult) in data.enumerated() {
            options.itemId = number
            str += singleShapeData(color: shapeResult.color, shape: shapeResult.shape, options: options)
        }

        str += "</svg>"

        return str
    }

    private func shapeData(rectangle r: Rectangle) -> String {
        "<rect x=\"\(min(r.x1, r.x2))\" y=\"\(min(r.y1, r.y2))\" width=\"\(max(r.x1, r.x2) - min(r.x1, r.x2))\" height=\"\(max(r.y1, r.y2) - min(r.y1, r.y2))\" \(svg_style_hook) />"
    }

    private func shapeData(rotatedRectangle r: RotatedRectangle) -> String {
        let cp = r.cornerPoints
        return "<polygon points=\"\(cp.0.x),\(cp.0.y) \(cp.1.x),\(cp.1.y) \(cp.2.x),\(cp.2.y) \(cp.3.x),\(cp.3.y)\" \(svg_style_hook)/>"
    }

    private func shapeData(rotatedRectangle r: RotatedEllipse) -> String {
        "<g transform=\"translate(\(r.x) \(r.y)) rotate(\(r.angleDegrees)) scale(\(r.rx) \(r.ry))\"><ellipse cx=\"0\" cy=\"0\" rx=\"1\" ry=\"1\" \(svg_style_hook) /></g>"
    }

    private func shapeData(triangle t: Triangle) -> String {
        "<polygon points=\"\(t.x1),\(t.y1) \(t.x2),\(t.y2) \(t.x3),\(t.y3)\" \(svg_style_hook)/>"
    }

    private func shapeData(circle c: Circle) -> String {
        "<circle cx=\"\(c.x)\" cy=\"\(c.y)\" r=\"\(c.r)\" \(svg_style_hook)/>"
    }

    private func shapeData(ellipse e: Ellipse) -> String {
        "<ellipse cx=\"\(e.x)\" cy=\"\(e.y)\" rx=\"\(e.rx)\" ry=\"\(e.ry)\" \(svg_style_hook)/>"
    }

    private func shapeData(line l: Line) -> String {
        "<line x1=\"\(l.x1)\" y1=\"\(l.y1)\" x2=\"\(l.x2)\" y2=\"\(l.y2)\" \(svg_style_hook)/>"
    }

    private func shapeData(polyline l: Polyline) -> String {
        "<polyline points=\"" + l.points.map { "\($0.x),\($0.y)" }.joined(separator: " ") + "\" \(svg_style_hook) />"
    }

    private func shapeData(quadraticBezier q: QuadraticBezier) -> String {
        // TODO: have to do something with double coordinates in shapes
        "<path d=\"M\(Int(q.x1)) \(Int(q.y1)) Q \(Int(q.cx)) \(Int(q.cy)) \(Int(q.x2)) \(Int(q.y2))\" \(svg_style_hook)/>"
    }

    private func shapeData(shape: any Shape, options: ExportOptions) -> String {
        switch shape {
        case let rectangle as Rectangle:
            return shapeData(rectangle: rectangle)
        case let rotatedRectangle as RotatedRectangle:
            return shapeData(rotatedRectangle: rotatedRectangle)
        case let rotatedEllipse as RotatedEllipse:
            return shapeData(rotatedRectangle: rotatedEllipse)
        case let triangle as Triangle:
            return shapeData(triangle: triangle)
        case let circle as Circle:
            return shapeData(circle: circle)
        case let ellipse as Ellipse:
            return shapeData(ellipse: ellipse)
        case let line as Line:
            return shapeData(line: line)
        case let polyline as Polyline:
            return shapeData(polyline: polyline)
        case let quadraticBezier as QuadraticBezier:
            return shapeData(quadraticBezier: quadraticBezier)
        default:
            fatalError("Unexpected type \(type(of: shape)) of shape.")
        }
    }

    private func rgbColorAttrib(color: Rgba) -> String {
        "rgb(\(color.r),\(color.g),\(color.b))"
    }

    private func strokeAttrib(color: Rgba) -> String {
        "stroke=\"\(rgbColorAttrib(color: color))\""
    }

    private func fillAttrib(color: Rgba) -> String {
        "fill=\"\(rgbColorAttrib(color: color))\""
    }

    private func fillOpacityAttrib(color: Rgba) -> String {
        "fill-opacity=\"\(Double(color.a) / 255.0)\""
    }

    private func strokeOpacityAttrib(color: Rgba) -> String {
        "stroke-opacity=\"\(Double(color.a) / 255.0)\""
    }

}
