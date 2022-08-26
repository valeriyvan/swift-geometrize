import XCTest
@testable import geometrize

final class CoreTests: XCTestCase {
    
    func testDifferenceFull() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)
        XCTAssertEqual(differenceFull(first: blackBitmap, second: blackBitmap), 0)

        var bitmap1 = blackBitmap
        bitmap1[0, 0] = .white
        
        var bitmap2 = bitmap1
        bitmap2[0, 1] = .white
        
        XCTAssertTrue(differenceFull(first: blackBitmap, second: bitmap2) > differenceFull(first: blackBitmap, second: bitmap1))
    }

}
