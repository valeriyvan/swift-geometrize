import XCTest
@testable import Geometrize

final class SVGExporterTests: XCTestCase {
    
    let exporter = SVGExporter()
    
    // MARK: - Individual Shape Export Tests
    
    func testExportSingleRectangle() {
        let rectangle = Rectangle(strokeWidth: 1, x1: 10.0, y1: 20.0, x2: 100.0, y2: 80.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 255, g: 0, b: 0, a: 200),
            shape: rectangle,
            width: 200,
            height: 150,
            originWidth: 200,
            originHeight: 150
        )
        
        XCTAssertTrue(svg.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"))
        XCTAssertTrue(svg.contains("<svg xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\""))
        XCTAssertTrue(svg.contains("width=\"200\" height=\"150\" viewBox=\"0 0 200 150\">"))
        XCTAssertTrue(svg.contains("<rect x=\"10.0\" y=\"20.0\" width=\"90.0\" height=\"60.0\""))
        XCTAssertTrue(svg.contains("fill=\"rgb(255,0,0)\""))
        XCTAssertTrue(svg.contains("fill-opacity=\"0.7843137254901961\""))
        XCTAssertTrue(svg.contains("</svg>"))
    }
    
    func testExportSingleCircle() {
        let circle = Circle(strokeWidth: 1, x: 50.0, y: 75.0, r: 25.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 0, g: 255, b: 0, a: 128),
            shape: circle,
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<circle cx=\"50.0\" cy=\"75.0\" r=\"25.0\""))
        XCTAssertTrue(svg.contains("fill=\"rgb(0,255,0)\""))
        XCTAssertTrue(svg.contains("fill-opacity=\"0.5019607843137255\""))
    }
    
    func testExportSingleEllipse() {
        let ellipse = Ellipse(strokeWidth: 1, x: 60.0, y: 40.0, rx: 30.0, ry: 20.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 0, g: 0, b: 255, a: 255),
            shape: ellipse,
            width: 120,
            height: 80,
            originWidth: 120,
            originHeight: 80
        )
        
        XCTAssertTrue(svg.contains("<ellipse cx=\"60.0\" cy=\"40.0\" rx=\"30.0\" ry=\"20.0\""))
        XCTAssertTrue(svg.contains("fill=\"rgb(0,0,255)\""))
        XCTAssertTrue(svg.contains("fill-opacity=\"1.0\""))
    }
    
    func testExportSingleTriangle() {
        let triangle = Triangle(strokeWidth: 1, x1: 10.0, y1: 80.0, x2: 50.0, y2: 20.0, x3: 90.0, y3: 80.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 255, g: 255, b: 0, a: 100),
            shape: triangle,
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<polygon points=\"10.0,80.0 50.0,20.0 90.0,80.0\""))
        XCTAssertTrue(svg.contains("fill=\"rgb(255,255,0)\""))
        XCTAssertTrue(svg.contains("fill-opacity=\"0.39215686274509803\""))
    }
    
    func testExportSingleRotatedRectangle() {
        let rotatedRect = RotatedRectangle(strokeWidth: 1, x1: 20.0, y1: 30.0, x2: 80.0, y2: 70.0, angleDegrees: 45.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 128, g: 64, b: 192, a: 180),
            shape: rotatedRect,
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<polygon points="))
        XCTAssertTrue(svg.contains("fill=\"rgb(128,64,192)\""))
        XCTAssertTrue(svg.contains("fill-opacity=\"0.7058823529411765\""))
    }
    
    func testExportSingleRotatedEllipse() {
        let rotatedEllipse = RotatedEllipse(strokeWidth: 1, x: 50.0, y: 50.0, rx: 30.0, ry: 15.0, angleDegrees: 30.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 200, g: 100, b: 50, a: 220),
            shape: rotatedEllipse,
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<g transform=\"translate(50.0 50.0) rotate(30.0) scale(30.0 15.0)\">"))
        XCTAssertTrue(svg.contains("<ellipse cx=\"0\" cy=\"0\" rx=\"1\" ry=\"1\""))
        XCTAssertTrue(svg.contains("</g>"))
        XCTAssertTrue(svg.contains("fill=\"rgb(200,100,50)\""))
    }
    
    // MARK: - Stroke-based Shape Tests (Line, Polyline, QuadraticBezier)
    
    func testExportSingleLine() {
        let line = Line(strokeWidth: 3, x1: 10.0, y1: 20.0, x2: 90.0, y2: 80.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 255, g: 128, b: 64, a: 160),
            shape: line,
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<line x1=\"10.0\" y1=\"20.0\" x2=\"90.0\" y2=\"80.0\""))
        XCTAssertTrue(svg.contains("stroke=\"rgb(255,128,64)\""))
        XCTAssertTrue(svg.contains("stroke-width=\"3\""))
        XCTAssertTrue(svg.contains("fill=\"none\""))
        XCTAssertTrue(svg.contains("stroke-opacity=\"0.6274509803921569\""))
    }
    
    func testExportSinglePolyline() {
        let polyline = Polyline(strokeWidth: 2, points: [
            Point(x: 10.0, y: 10.0),
            Point(x: 50.0, y: 30.0),
            Point(x: 90.0, y: 10.0),
            Point(x: 70.0, y: 50.0)
        ])
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 64, g: 192, b: 128, a: 200),
            shape: polyline,
            width: 100,
            height: 60,
            originWidth: 100,
            originHeight: 60
        )
        
        XCTAssertTrue(svg.contains("<polyline points=\"10.0,10.0 50.0,30.0 90.0,10.0 70.0,50.0\""))
        XCTAssertTrue(svg.contains("stroke=\"rgb(64,192,128)\""))
        XCTAssertTrue(svg.contains("stroke-width=\"2\""))
        XCTAssertTrue(svg.contains("fill=\"none\""))
        XCTAssertTrue(svg.contains("stroke-opacity=\"0.7843137254901961\""))
    }
    
    func testExportSingleQuadraticBezier() {
        let bezier = QuadraticBezier(strokeWidth: 4, cx: 50.0, cy: 10.0, x1: 10.0, y1: 50.0, x2: 90.0, y2: 50.0)
        let svg = exporter.exportSingleShape(
            color: Rgba(r: 150, g: 75, b: 225, a: 255),
            shape: bezier,
            width: 100,
            height: 60,
            originWidth: 100,
            originHeight: 60
        )
        
        XCTAssertTrue(svg.contains("<path d=\"M10 50 Q50 10 90 50\""))
        XCTAssertTrue(svg.contains("stroke=\"rgb(150,75,225)\""))
        XCTAssertTrue(svg.contains("stroke-width=\"4\""))
        XCTAssertTrue(svg.contains("fill=\"none\""))
        XCTAssertTrue(svg.contains("stroke-opacity=\"1.0\""))
    }
    
    // MARK: - Complete SVG Export Tests
    
    func testExportCompleteSVGMultipleShapes() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba(r: 255, g: 0, b: 0, a: 128), shape: Rectangle(strokeWidth: 1, x1: 10.0, y1: 10.0, x2: 50.0, y2: 30.0)),
            ShapeResult(score: 0.2, color: Rgba(r: 0, g: 255, b: 0, a: 180), shape: Circle(strokeWidth: 1, x: 75.0, y: 20.0, r: 15.0)),
            ShapeResult(score: 0.3, color: Rgba(r: 0, g: 0, b: 255, a: 200), shape: Triangle(strokeWidth: 1, x1: 20.0, y1: 60.0, x2: 40.0, y2: 40.0, x3: 60.0, y3: 60.0))
        ]
        
        let svg = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,
            height: 80,
            originWidth: 200,
            originHeight: 160
        )
        
        XCTAssertTrue(svg.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"))
        XCTAssertTrue(svg.contains("width=\"200\" height=\"160\" viewBox=\"0 0 100 80\">"))
        XCTAssertTrue(svg.contains("<rect x=\"10.0\" y=\"10.0\" width=\"40.0\" height=\"20.0\""))
        XCTAssertTrue(svg.contains("<circle cx=\"75.0\" cy=\"20.0\" r=\"15.0\""))
        XCTAssertTrue(svg.contains("<polygon points=\"20.0,60.0 40.0,40.0 60.0,60.0\""))
        XCTAssertTrue(svg.contains("</svg>"))
    }
    
    func testExportCompleteSVGWithUpdateMarker() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba.red, shape: Rectangle(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0))
        ]
        
        let svg = exporter.exportCompleteSVG(
            data: shapes,
            width: 20,
            height: 20,
            originWidth: 20,
            originHeight: 20,
            scaleFactor: 1.0,
            updateMarker: "<!-- INSERT NEW SHAPES HERE -->"
        )
        
        XCTAssertTrue(svg.contains("<!-- INSERT NEW SHAPES HERE -->"))
        XCTAssertTrue(svg.contains("</svg>"))
    }
    
    func testExportCompleteSVGWithScaleFactor() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba.blue, shape: Circle(strokeWidth: 1, x: 25.0, y: 25.0, r: 20.0))
        ]
        
        let svg = exporter.exportCompleteSVG(
            data: shapes,
            width: 50,
            height: 50,
            originWidth: 100,
            originHeight: 100,
            scaleFactor: 2.0
        )
        
        XCTAssertTrue(svg.contains("width=\"100\" height=\"100\" viewBox=\"0 0 50 50\">"))
        XCTAssertTrue(svg.contains("<circle cx=\"25.0\" cy=\"25.0\" r=\"20.0\""))
    }
    
    // MARK: - Fragment Export Tests
    
    func testExportShapesAsSVGFragment() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba(r: 255, g: 100, b: 50, a: 255), shape: Rectangle(strokeWidth: 1, x1: 5.0, y1: 5.0, x2: 15.0, y2: 10.0)),
            ShapeResult(score: 0.2, color: Rgba(r: 50, g: 255, b: 100, a: 128), shape: Line(strokeWidth: 2, x1: 0.0, y1: 0.0, x2: 20.0, y2: 15.0))
        ]
        
        let fragment = exporter.exportShapesAsSVGFragment(data: shapes)
        
        XCTAssertTrue(fragment.contains("<rect x=\"5.0\" y=\"5.0\" width=\"10.0\" height=\"5.0\""))
        XCTAssertTrue(fragment.contains("fill=\"rgb(255,100,50)\""))
        XCTAssertTrue(fragment.contains("<line x1=\"0.0\" y1=\"0.0\" x2=\"20.0\" y2=\"15.0\""))
        XCTAssertTrue(fragment.contains("stroke=\"rgb(50,255,100)\""))
        XCTAssertFalse(fragment.contains("<?xml"))
        XCTAssertFalse(fragment.contains("<svg"))
        XCTAssertFalse(fragment.contains("</svg>"))
    }
    
    // MARK: - Coordinate Scaling and ViewBox Tests
    
    func testCoordinateScalingDifferentDimensions() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba.red, shape: Rectangle(strokeWidth: 1, x1: 10.0, y1: 20.0, x2: 90.0, y2: 80.0))
        ]
        
        let svg = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,    // downscaled width
            height: 100,   // downscaled height  
            originWidth: 400,   // original width (4x larger)
            originHeight: 200   // original height (2x larger)
        )
        
        // Should use originWidth/Height for SVG dimensions, width/height for viewBox
        XCTAssertTrue(svg.contains("width=\"400\" height=\"200\""))
        XCTAssertTrue(svg.contains("viewBox=\"0 0 100 100\""))
        
        // Rectangle coordinates should remain unchanged (no automatic scaling applied)
        XCTAssertTrue(svg.contains("<rect x=\"10.0\" y=\"20.0\" width=\"80.0\" height=\"60.0\""))
    }
    
    func testViewBoxWithDifferentAspectRatios() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba.blue, shape: Circle(strokeWidth: 1, x: 25.0, y: 50.0, r: 20.0))
        ]
        
        // Wide aspect ratio
        let wideSvg = exporter.exportCompleteSVG(
            data: shapes,
            width: 200,
            height: 100,
            originWidth: 800,
            originHeight: 200
        )
        XCTAssertTrue(wideSvg.contains("width=\"800\" height=\"200\" viewBox=\"0 0 200 100\">"))
        
        // Tall aspect ratio
        let tallSvg = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,
            height: 200,
            originWidth: 300,
            originHeight: 900
        )
        XCTAssertTrue(tallSvg.contains("width=\"300\" height=\"900\" viewBox=\"0 0 100 200\">"))
    }
    
    func testScaleFactorParameter() {
        let shapes = [
            ShapeResult(score: 0.1, color: Rgba.green, shape: Ellipse(strokeWidth: 1, x: 50.0, y: 30.0, rx: 25.0, ry: 15.0))
        ]
        
        // Test with different scale factors (though currently not used in implementation)
        let svg1 = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,
            height: 60,
            originWidth: 200,
            originHeight: 120,
            scaleFactor: 2.0
        )
        
        let svg2 = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,
            height: 60,
            originWidth: 200,
            originHeight: 120,
            scaleFactor: 0.5
        )
        
        // Both should produce identical output since scaleFactor is not currently used
        XCTAssertTrue(svg1.contains("width=\"200\" height=\"120\" viewBox=\"0 0 100 60\">"))
        XCTAssertTrue(svg2.contains("width=\"200\" height=\"120\" viewBox=\"0 0 100 60\">"))
        XCTAssertEqual(svg1, svg2) // Should be identical
    }
    
    func testCoordinatePrecisionInSVG() {
        // Test floating point coordinate precision
        let rect = Rectangle(strokeWidth: 1, x1: 10.123456, y1: 20.987654, x2: 90.555555, y2: 80.777777)
        let svg = exporter.exportSingleShape(
            color: Rgba.black,
            shape: rect,
            width: 100, height: 100, originWidth: 100, originHeight: 100
        )
        
        // Should preserve floating point precision
        XCTAssertTrue(svg.contains("x=\"10.123456\""))
        XCTAssertTrue(svg.contains("y=\"20.987654\""))
        XCTAssertTrue(svg.contains("width=\"80.432099\"")) // 90.555555 - 10.123456
        XCTAssertTrue(svg.contains("height=\"59.790123\"")) // 80.777777 - 20.987654
    }
    
    func testViewBoxWithZeroDimensions() {
        let shapes = [ShapeResult(score: 0.1, color: Rgba.red, shape: Rectangle(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: 1.0, y2: 1.0))]
        
        // Test edge cases with zero dimensions
        let zeroWidthSvg = exporter.exportCompleteSVG(
            data: shapes,
            width: 0,
            height: 100,
            originWidth: 0,
            originHeight: 100
        )
        XCTAssertTrue(zeroWidthSvg.contains("width=\"0\" height=\"100\" viewBox=\"0 0 0 100\">"))
        
        let zeroHeightSvg = exporter.exportCompleteSVG(
            data: shapes,
            width: 100,
            height: 0,
            originWidth: 100,
            originHeight: 0
        )
        XCTAssertTrue(zeroHeightSvg.contains("width=\"100\" height=\"0\" viewBox=\"0 0 100 0\">"))
    }

    // MARK: - Edge Cases and Error Conditions
    
    func testExportEmptyShapeArray() {
        let svg = exporter.exportCompleteSVG(
            data: [],
            width: 100,
            height: 100,
            originWidth: 100,
            originHeight: 100
        )
        
        XCTAssertTrue(svg.contains("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"))
        XCTAssertTrue(svg.contains("<svg xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\""))
        XCTAssertTrue(svg.contains("</svg>"))
        // Should contain only the SVG wrapper, no shape elements
        XCTAssertFalse(svg.contains("<rect"))
        XCTAssertFalse(svg.contains("<circle"))
    }
    
    func testColorFormattingEdgeCases() {
        // Test pure black
        let blackRect = Rectangle(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0)
        let blackSvg = exporter.exportSingleShape(
            color: Rgba(r: 0, g: 0, b: 0, a: 255),
            shape: blackRect,
            width: 20, height: 20, originWidth: 20, originHeight: 20
        )
        XCTAssertTrue(blackSvg.contains("fill=\"rgb(0,0,0)\""))
        XCTAssertTrue(blackSvg.contains("fill-opacity=\"1.0\""))
        
        // Test pure white
        let whiteRect = Rectangle(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0)
        let whiteSvg = exporter.exportSingleShape(
            color: Rgba(r: 255, g: 255, b: 255, a: 255),
            shape: whiteRect,
            width: 20, height: 20, originWidth: 20, originHeight: 20
        )
        XCTAssertTrue(whiteSvg.contains("fill=\"rgb(255,255,255)\""))
        XCTAssertTrue(whiteSvg.contains("fill-opacity=\"1.0\""))
        
        // Test fully transparent
        let transparentRect = Rectangle(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0)
        let transparentSvg = exporter.exportSingleShape(
            color: Rgba(r: 128, g: 128, b: 128, a: 0),
            shape: transparentRect,
            width: 20, height: 20, originWidth: 20, originHeight: 20
        )
        XCTAssertTrue(transparentSvg.contains("fill=\"rgb(128,128,128)\""))
        XCTAssertTrue(transparentSvg.contains("fill-opacity=\"0.0\""))
    }
    
}