import XCTest
@testable import Geometrize

final class RgbaTests: XCTestCase {

    func testBlending() {
        XCTAssertEqual(
            Rgba.red.blending(background: .white),
            .red
        )
        XCTAssertEqual(
            Rgba.red.withAlphaComponent(128).blending(background: .white),
            Rgba(r: 255, g: 127, b: 127, a: 255)
        )
    }

    func testArray() {
        let array: [UInt8] = [1, 2, 3, 4]
        let rgba = Rgba(array)
        XCTAssertEqual(rgba.asArray, array)
    }

    func testTuple() {
        let tuple = (UInt8(1), UInt8(2), UInt8(3), UInt8(4))
        let rgba = Rgba(tuple)
        XCTAssertTrue(rgba.asTuple == tuple)
    }

}
