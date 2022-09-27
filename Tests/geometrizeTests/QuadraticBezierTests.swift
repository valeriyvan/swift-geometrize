import XCTest
import SnapshotTesting
@testable import geometrize

final class QuadraticBezierTests: XCTestCase {
    
    func testRasterize() throws {
        let xMax = 471, yMax = 590
        var bitmap = Bitmap(width: xMax, height: yMax, color: .red)
        bitmap.draw(
            lines:
                QuadraticBezier(cx: 327.0, cy: 295.0, x1: 57.0, y1: 542.0, x2: 190.0, y2: 216.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .white
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 471, height: 590, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
