import Foundation

public struct SVGExporter {

    public init() {}

    /// A hook that an SVG exporter should use to augment shape styling produced by the getSvgShapeData method.
    private let svg_style_hook = "::svg_style_hook::" // swiftlint:disable:this identifier_name

    /// Gets the SVG data for a single shape. This is just the <rect>/<path> etc block for the shape itself,
    /// not a complete SVG image.
    /// - Parameters:
    ///   - color: The color of the shape
    ///   - shape: The shape to convert to SVG data
    /// - Returns: The SVG shape data for the given shape
    func singleShapeData(color: Rgba, shape: any Shape) -> String {
        var shapeData: String = shapeData(shape: shape)

        var styles: String = ""
        if shape.self is Line || shape.self is Polyline || shape.self is QuadraticBezier {
            styles += strokeAttrib(color: color)
            styles += " stroke-width=\"\(Int(shape.strokeWidth))\" fill=\"none\" "
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
    ///   - originWidth: The width of the original image.
    ///   - originHeight: The height of the original image.
    /// - Returns: A string representing the SVG image.
    func exportSingleShape( // swiftlint:disable:this function_parameter_count
        color: Rgba,
        shape: any Shape,
        width: Int,
        height: Int,
        originWidth: Int,
        originHeight: Int
    ) -> String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" xmlns="http://www.w3.org/2000/svg"
        width=\"\(width)\" height=\"\(height)\" viewBox=\"0 0 \(width) \(height)\">
        \(singleShapeData(color: color, shape: shape))
        </svg>
        """
    }

    /// Exports shape data as a complete SVG image.
    /// - Parameters:
    ///   - data The shape data to export.
    ///   - width The width of the SVG image.
    ///   - height The height of the SVG image.
    ///   - originWidth: The width of the original image.
    ///   - originHeight: The height of the original image.
    ///   - updateMarker place where new elements should be inserted. Better if this will be correct XML comment.
    /// - Returns: A string representing the SVG image.
    public func exportCompleteSVG(
        data: [ShapeResult],
        width: Int,
        height: Int,
        originWidth: Int,
        originHeight: Int,
        updateMarker: String? = nil
    ) -> String {
        var str = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" xmlns="http://www.w3.org/2000/svg"
        width=\"\(width)\" height=\"\(height)\" viewBox=\"0 0 \(width) \(height)\">\n
        """
        str += exportShapesAsSVGFragment(data: data)
        if let updateMarker {
            str += updateMarker
        }
        str += "</svg>"
        return str
    }

    public func exportShapesAsSVGFragment(data: [ShapeResult]) -> String {
        data.reduce(into: "") { $0 += singleShapeData(color: $1.color, shape: $1.shape) }
    }

    private func shapeData(rectangle r: Rectangle) -> String {
        "<rect x=\"\(min(r.x1, r.x2))\" y=\"\(min(r.y1, r.y2))\" " +
        "width=\"\(max(r.x1, r.x2) - min(r.x1, r.x2))\" height=\"\(max(r.y1, r.y2) - min(r.y1, r.y2))\" " +
        "\(svg_style_hook)/>"
    }

    private func shapeData(rotatedRectangle r: RotatedRectangle) -> String {
        "<polygon points=\"" +
        "\(r.cornerPoints.0.x),\(r.cornerPoints.0.y) " +
        "\(r.cornerPoints.1.x),\(r.cornerPoints.1.y) " +
        "\(r.cornerPoints.2.x),\(r.cornerPoints.2.y) " +
        "\(r.cornerPoints.3.x),\(r.cornerPoints.3.y)\" " +
        "\(svg_style_hook)/>"
    }

    private func shapeData(rotatedRectangle r: RotatedEllipse) -> String {
        "<g transform=\"translate(\(r.x) \(r.y)) rotate(\(r.angleDegrees)) scale(\(r.rx) \(r.ry))\">" +
        "<ellipse cx=\"0\" cy=\"0\" rx=\"1\" ry=\"1\" \(svg_style_hook)/>" +
        "</g>"
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
        "<polyline points=\"" + l.points.map { "\($0.x),\($0.y)" }.joined(separator: " ") + "\" \(svg_style_hook)/>"
    }

    private func shapeData(quadraticBezier q: QuadraticBezier) -> String {
        // TODO: have to do something with double coordinates in shapes
        "<path d=\"M\(Int(q.x1)) \(Int(q.y1)) Q\(Int(q.cx)) \(Int(q.cy)) \(Int(q.x2)) \(Int(q.y2))\" \(svg_style_hook)/>"
    }

    private func shapeData(shape: any Shape) -> String {
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
