import XCTest
@testable import Geometrize

final class ShapeTypesTests: XCTestCase {

    func testEmpty() throws {
        XCTAssertTrue([String]().shapeTypes().isEmpty)
    }

    func testRectangle() throws {
        let array = ["rectangle"].shapeTypes().compactMap { $0 }
        XCTAssertEqual(array.count, 1)
        XCTAssert(array[0] is Rectangle.Type)
    }

    func testRotated_Rectangle() throws {
        let array = ["Rotated_rectangle"].shapeTypes().compactMap { $0 }
        XCTAssertEqual(array.count, 1)
        XCTAssert(array[0] is RotatedRectangle.Type)
    }

    func testRectangleCircleGarbage() throws {
        var array = ["Rectangle", "Circle", "bla-bla-bla"].shapeTypes()
        XCTAssertEqual(array.count, 3)
        XCTAssertNil(array[2])
        array = array.compactMap { $0 }
        XCTAssert(array[0] is Rectangle.Type)
        XCTAssert(array[1] is Circle.Type)
    }

}
