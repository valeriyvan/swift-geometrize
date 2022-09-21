import XCTest
@testable import geometrize

final class ClampedTests: XCTestCase {
    
    func test() throws {
        XCTAssertEqual(7.clamped(to: 5...10), 7)
        XCTAssertEqual(5.clamped(to: 5...10), 5)
        XCTAssertEqual(3.clamped(to: 5...10), 5)
        XCTAssertEqual(10.clamped(to: 5...10), 10)
        XCTAssertEqual(20.clamped(to: 5...10), 10)
    }
    
}
