import XCTest
@testable import geometrize

final class CoreTests: XCTestCase {
    
    func testDifferenceFull() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)
        
        // Difference with itself is 0
        XCTAssertEqual(differenceFull(first: blackBitmap, second: blackBitmap), 0)

        var blackBitmapOnePixelChanged = blackBitmap
        blackBitmapOnePixelChanged[0, 0] = .white
        var blackBitmapTwoPixelsChanged = blackBitmapOnePixelChanged
        blackBitmapTwoPixelsChanged[0, 1] = .white
        
        // Changing two pixels means there's more difference than changing one.
        XCTAssertTrue(differenceFull(first: blackBitmap, second: blackBitmapTwoPixelsChanged) > differenceFull(first: blackBitmap, second: blackBitmapOnePixelChanged))

        // Now the same for white image
        
        let whiteBitmap = Bitmap(width: 10, height: 10, color: .white)

        // Difference with itself is 0
        XCTAssertEqual(differenceFull(first: whiteBitmap, second: whiteBitmap), 0)

        var whiteBitmapOnePixelChanged = whiteBitmap
        whiteBitmapOnePixelChanged[0, 0] = .black
        var whiteBitmapTwoPixelsChanged = whiteBitmapOnePixelChanged
        whiteBitmapTwoPixelsChanged[0, 1] = .black
        
        // Changing two pixels means there's more difference than changing one.
        XCTAssertTrue(differenceFull(first: whiteBitmap, second: whiteBitmapTwoPixelsChanged) > differenceFull(first: whiteBitmap, second: whiteBitmapOnePixelChanged))
    }

}
