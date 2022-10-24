import XCTest
@testable import Geometrize

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
            Scanline(y: 3, x1: 3, x2: 13), // 1
            Scanline(y: 4, x1: 3, x2: 13), // 2
            Scanline(y: 5, x1: 3, x2: 13), // 3
            Scanline(y: 5, x1: 7, x2: 9),  // 4
            Scanline(y: 6, x1: 3, x2: 13)  // 5
        ]
        let trimmed = scanlines.trimmed(minX: 5, minY: 4, maxX: 10, maxY: 5)
        let trimmedSample = [
            Scanline(y: 4, x1: 5, x2: 10), // 2
            Scanline(y: 5, x1: 5, x2: 10), // 3
            Scanline(y: 5, x1: 7, x2: 9)   // 4
        ]
        XCTAssertEqual(trimmed, trimmedSample)
    }

    func testStringConversion() {
        let line = Scanline(y: 3, x1: 3, x2: 13)
        XCTAssertEqual(Scanline(stringLiteral: line.description), line)
    }

}
