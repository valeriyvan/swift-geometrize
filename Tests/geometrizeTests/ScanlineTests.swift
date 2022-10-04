import XCTest
@testable import geometrize

final class ScanlineTests: XCTestCase {

    func testInit() throws {
        let scanline = Scanline()
        XCTAssertEqual(scanline.y, 0)
        XCTAssertEqual(scanline.x1, 0)
        XCTAssertEqual(scanline.x2, 0)
    }

    func testInitWithCoordinates() throws {
        let scanline = Scanline(y: 1, x1: 2, x2: 3)
        XCTAssertEqual(scanline.y, 1)
        XCTAssertEqual(scanline.x1, 2)
        XCTAssertEqual(scanline.x2, 3)
    }

    func testTrimmed() throws {
        let scanlines = [
            Scanline(y: 3, x1: 3, x2: 13),
            Scanline(y: 4, x1: 3, x2: 13),
            Scanline(y: 5, x1: 3, x2: 13)
        ]
        let trimmed = scanlines.trimmed(minX: 5, minY: 4, maxX: 10, maxY: 5)
        let trimmedSample = [
            Scanline(y: 4, x1: 5, x2: 9)
        ]
        XCTAssertEqual(trimmed, trimmedSample)
    }

    func testStringConversion() {
        let line = Scanline(y: 3, x1: 3, x2: 13)
        XCTAssertEqual(Scanline(stringLiteral: line.description), line)
    }

}
