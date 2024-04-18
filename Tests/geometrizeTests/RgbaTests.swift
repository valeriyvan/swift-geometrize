import XCTest
@testable import Geometrize

final class RgbaTests: XCTestCase {

    func testBlending() {
        XCTAssertEqual(Rgba.red.blending(background: .white), .red)
        XCTAssertEqual(Rgba.red.withAlphaComponent(128).blending(background: .white), Rgba(r: 255, g: 127, b: 127, a: 255))
    }

}
