import XCTest
@testable import geometrize

final class BitmapTests: XCTestCase {
    
    func testInit() throws {
        let bitmap = Bitmap()
        XCTAssertEqual(bitmap.width, 0)
        XCTAssertEqual(bitmap.height, 0)
        XCTAssertEqual(bitmap.data, [])
        XCTAssertTrue(bitmap.isEmpty)
    }

    func testInitSizeAndColor() throws {
        let blackBitmap = Bitmap(width: 5, height: 7, color: Rgba(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(blackBitmap.width, 5)
        XCTAssertEqual(blackBitmap.height, 7)
        XCTAssertEqual(blackBitmap.data.count, 5 * 7 * 4)
        XCTAssertEqual(blackBitmap.data, [UInt8].init(repeating: 0, count: 5 * 7 * 4))
        XCTAssertFalse(blackBitmap.isEmpty)

        let whiteBitmap = Bitmap(width: 8, height: 6, color: .white)
        XCTAssertEqual(whiteBitmap.width, 8)
        XCTAssertEqual(whiteBitmap.height, 6)
        XCTAssertEqual(whiteBitmap.data.count, 8 * 6 * 4)
        XCTAssertEqual(whiteBitmap.data, [UInt8].init(repeating: 255, count: 8 * 6 * 4))
        XCTAssertFalse(whiteBitmap.isEmpty)
    }

    func testInitSizeAndBitmap() throws {
        let data: [UInt8] = [
            0,0,0,0,     1,1,1,1,     2,2,2,2,     3,3,3,3,     4,4,4,4,
            10,10,10,10, 11,11,11,11, 12,12,12,12, 13,13,13,13, 14,14,14,14,
            20,20,20,20, 21,21,21,21, 22,22,22,22, 23,23,23,23, 24,24,24,24
        ]
        let bitmap = Bitmap(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap.width, 5)
        XCTAssertEqual(bitmap.height, 3)
        XCTAssertEqual(bitmap.data.count, 5 * 3 * 4)
        XCTAssertEqual(bitmap.data, data)
    }

    func testSubscript() throws {
        let data: [UInt8] = [
            0,0,0,0,     1,1,1,1,     2,2,2,2,     3,3,3,3,     4,4,4,4,
            10,10,10,10, 11,11,11,11, 12,12,12,12, 13,13,13,13, 14,14,14,14,
            20,20,20,20, 21,21,21,21, 22,22,22,22, 23,23,23,23, 24,24,24,24
        ]
        var bitmap = Bitmap(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap[0, 0], Rgba(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(bitmap[4, 2], Rgba(r: 24, g: 24, b: 24, a: 24))
        XCTAssertEqual(bitmap[1, 1], Rgba(r: 11, g: 11, b: 11, a: 11))
        bitmap[1, 1] = Rgba(r: 111, g: 111, b: 111, a: 111)
        bitmap[3, 2] = Rgba(r: 222, g: 222, b: 222, a: 222)
        XCTAssertEqual(
            bitmap.data, [
                0,0,0,0,     1,1,1,1,         2,2,2,2,     3,3,3,3,         4,4,4,4,
                10,10,10,10, 111,111,111,111, 12,12,12,12, 13,13,13,13,     14,14,14,14,
                20,20,20,20, 21,21,21,21,     22,22,22,22, 222,222,222,222, 24,24,24,24
            ] as [UInt8]
        )
    }

    func testFill() throws {
        var bitmap = Bitmap(width: 5, height: 7, color: .black)
        let color = Rgba(r: 1, g: 2, b: 3, a: 128)
        bitmap.fill(color: color)
        let sampleBitmap = Bitmap(width: 5, height: 7, color: color)
        XCTAssertEqual(bitmap, sampleBitmap)
    }
}
