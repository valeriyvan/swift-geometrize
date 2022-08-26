import Foundation

// A hook that an SVG exporter should use to augment shape styling produced by the getSvgShapeData method.
fileprivate let SVG_STYLE_HOOK = "::svg_style_hook::"

enum RotatedEllipseSVGExportMode {
    // Export as a translated, rotated and scaled svg <ellipse>. OpenFL's SVG library can't handle this
    case ellipseItem
    // Export as a <polygon>, OpenFL's SVG library can handle this, but it looks quite ugly
    case polygon
};

// Represents the options that can be set for the SVG export.
struct SVGExportOptions {
    // Technique to use when exporting rotated ellipses
    let rotatedEllipseExportMode: RotatedEllipseSVGExportMode = .ellipseItem
    // Id to tag the exported SVG shapes with
    var itemId = 0
}

// Gets the SVG data for a single shape. This is just the <rect>/<path> etc block for the shape itself, not a complete SVG image.
// @param color The color of the shape.
// @param shape The shape to convert to SVG data.
// @param options additional options used by the exporter.
// @return The SVG shape data for the given shape.
func getSingleShapeSVGData(color: Rgba, shape: any Shape, options: SVGExportOptions = SVGExportOptions()) -> String {
    var shapeData: String = getSvgShapeData(shape: shape, options: options)
    let shapeType = shape.type()

    var styles: String = "id=\"\(options.itemId)\" "

    if [ShapeType.line, ShapeType.polyline, ShapeType.quadraticBezier].contains(shapeType) {
        styles += getSVGStrokeAttrib(color: color)
        styles += " stroke-width=\"1\" fill=\"none\" "
        styles += getSVGStrokeOpacityAttrib(color: color)
    } else {
        styles += getSVGFillAttrib(color: color)
        styles += " "
        styles += getSVGFillOpacityAttrib(color: color)
    }

    shapeData = shapeData.replacingOccurrences(of: SVG_STYLE_HOOK, with: styles)

    shapeData += "\n"

    return shapeData
}

// Exports a single shape as a complete SVG image.
// @param color The color of the shape to export.
// @param shape The shape to export.
// @param width The width of the SVG image.
// @param height The height of the SVG image.
// @param options additional options used by the exporter.
// @return A string representing the SVG image.
func exportSingleShapeSVG(color: Rgba, shape: any Shape, width: Int, height: Int, options: SVGExportOptions = SVGExportOptions()) -> String {
    """
    <?xml version=\"1.0\" standalone=\"no\"?>
    <svg xmlns=\"https://www.w3.org/2000/svg\" version=\"1.2\" baseProfile=\"tiny\" width=\"\(width)\" height=\"(height)\" viewBox=\"0 0 \(width) \(height)\">\n
    \(getSingleShapeSVGData(color: color, shape: shape, options: options))
    </svg>
    """
}

// Exports shape data as a complete SVG image.
// @param data The shape data to export.
// @param width The width of the SVG image.
// @param height The height of the SVG image.
// @param options additional options used by the exporter.
// @return A string representing the SVG image.
func exportSVG(data: [ShapeResult], width: Int, height: Int, options: SVGExportOptions = SVGExportOptions()) -> String {
    var str = """
    <?xml version=\"1.0\" standalone=\"no\"?>
    <svg xmlns=\"https://www.w3.org/2000/svg\" version=\"1.2\" baseProfile=\"tiny\" width=\"\(width)\" height=\"\(height)\" viewBox=\"0 0 \(width) \(height)\">
    """

    var options = options
    for (number, shapeResult) in data.enumerated() {
        options.itemId = number
        str += getSingleShapeSVGData(color: shapeResult.color, shape: shapeResult.shape, options: options)
    }

    str += "</svg>"

    return str
}

fileprivate func getSvgShapeData(rectangle r: Rectangle) -> String {
    "<rect x=\"\(min(r.x1, r.x2))\" y=\"\(min(r.y1, r.y2))\" width=\"\(max(r.x1, r.x2) - min(r.x1, r.x2))\" height=\"\(max(r.y1, r.y2) - min(r.y1, r.y2))\" \(SVG_STYLE_HOOK) />"
}

fileprivate func getSvgShapeData(shape s: Shape, options: SVGExportOptions) -> String {
    switch s.type() {
    case .rectangle:
        return getSvgShapeData(rectangle: s as! Rectangle)
    default:
        fatalError("Unimplemented")
    }
}

fileprivate func getSVGRgbColorAttrib(color: Rgba) -> String {
    "rgb(\(color.r),\(color.g),\(color.b))"
}

fileprivate func getSVGStrokeAttrib(color: Rgba) -> String {
    "stroke=\"\(getSVGRgbColorAttrib(color: color))\""
}

fileprivate func getSVGFillAttrib(color: Rgba) -> String {
    "fill=\"\(getSVGRgbColorAttrib(color: color))\""
}

fileprivate func getSVGFillOpacityAttrib(color: Rgba) -> String {
    "fill-opacity=\"\(Double(color.a) / 255.0)\""
}

fileprivate func getSVGStrokeOpacityAttrib(color: Rgba) -> String {
    "stroke-opacity=\"\(Double(color.a) / 255.0)\""
}