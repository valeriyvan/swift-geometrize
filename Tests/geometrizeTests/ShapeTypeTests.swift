import XCTest
@testable import Geometrize

final class ShapeTypeTests: XCTestCase {

    func testEmpty() throws {
        XCTAssertNil(shapeType(from: ""))
    }

    func testRectangle() throws {
        XCTAssert(shapeType(from: "Rectangle") is Rectangle.Type)
    }

    func testRotatedRectangle() throws {
        XCTAssert(shapeType(from: "RotatedRectangle") is RotatedRectangle.Type)
    }

    func testCircle() throws {
        XCTAssert(shapeType(from: "Circle") is Circle.Type)
    }

    func testEllipse() throws {
        XCTAssert(shapeType(from: "Ellipse") is Ellipse.Type)
    }

    func testRotatedEllipse() throws {
        XCTAssert(shapeType(from: "RotatedEllipse") is RotatedEllipse.Type)
    }

    func testTriangle() throws {
        XCTAssert(shapeType(from: "Triangle") is Triangle.Type)
    }

    func testLine() throws {
        XCTAssert(shapeType(from: "Line") is Line.Type)
    }

    func testPolyline() throws {
        XCTAssert(shapeType(from: "Polyline") is Polyline.Type)
    }

    func testQuadraticBezier() throws {
        XCTAssert(shapeType(from: "QuadraticBezier") is QuadraticBezier.Type)
    }

    func testBlaBlaBla() throws {
        XCTAssertNil(shapeType(from: "BlaBlaBla"))
    }
}
