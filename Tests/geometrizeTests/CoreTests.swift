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

    func testDifferenceFullComparingResultWithCPlusPlus() throws {
        let firstUrl = Bundle.module.url(forResource: "differenceFull bitmap first", withExtension: "txt")!
        let bitmapFirst = Bitmap(stringLiteral: try String(contentsOf: firstUrl))
        let secondUrl = Bundle.module.url(forResource: "differenceFull bitmap second", withExtension: "txt")!
        let bitmapSecond = Bitmap(stringLiteral: try String(contentsOf: secondUrl))
        XCTAssertEqual(differenceFull(first: bitmapFirst, second: bitmapSecond), 0.170819, accuracy: 0.000001)
    }
    
    func testDifferencePartialComparingResultWithCPlusPlus() throws {
        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap target", withExtension: "txt")!))
        let bitmapBefore = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap before", withExtension: "txt")!))
        let bitmapAfter = Bitmap(stringLiteral: try String(contentsOf: Bundle.module.url(forResource: "differencePartial bitmap after", withExtension: "txt")!))

        let scanlinesString = try String(contentsOf: Bundle.module.url(forResource: "differencePartial scanlines", withExtension: "txt")!)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        let scanlines = components.map(Scanline.init)
        
        XCTAssertEqual(
            differencePartial(
                target: bitmapTarget,
                before: bitmapBefore,
                after: bitmapAfter,
                score: 0.170819,
                lines: scanlines
            ),
            0.170800,
            accuracy: 0.000001
        )
    }

}
