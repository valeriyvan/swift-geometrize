import XCTest
@testable import geometrize

final class CoreTests: XCTestCase {
    
    func testDifferenceFull() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)
        
        // Difference with itself is 0
        XCTAssertEqual(differenceFull(first: blackBitmap, second: blackBitmap), 0)

        var bitmapOnePixelChanged = blackBitmap
        bitmapOnePixelChanged[0, 0] = .white
        var bitmapTwoPixelsChanged = bitmapOnePixelChanged
        bitmapTwoPixelsChanged[0, 1] = .white
        
        // Changing two pixels means there's more difference than changing one.
        XCTAssertTrue(differenceFull(first: blackBitmap, second: bitmapTwoPixelsChanged) > differenceFull(first: blackBitmap, second: bitmapOnePixelChanged))
    }

}
