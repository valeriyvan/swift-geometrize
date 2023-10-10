import XCTest
@testable import Geometrize

final class ShapeTypesTests: XCTestCase {

    func testEmpty() throws {
        XCTAssertTrue([String]().shapeTypes().isEmpty)
    }

    func testRectangle() throws {
        let array = ["rectangle"].shapeTypes()
        XCTAssertEqual(array.count, 1)
        XCTAssert(array[0]! is Rectangle.Type)
    }

    func testRotated_Rectangle() throws {
        let array = ["Rotated_rectangle"].shapeTypes()
        XCTAssertEqual(array.count, 1)
        XCTAssert(array[0]! is RotatedRectangle.Type)
    }

    func testRectangleCircleGarbage() throws {
        let array = ["Rectangle", "Circle", "bla-bla-bla"].shapeTypes()
        XCTAssertEqual(array.count, 3)
        XCTAssert(array[0]! is Rectangle.Type)
        XCTAssert(array[1]! is Circle.Type)
        XCTAssertNil(array[2])
    }

}
