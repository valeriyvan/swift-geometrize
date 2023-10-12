import XCTest
import SnapshotTesting
@testable import Geometrize

final class QuadraticBezierTests: XCTestCase {

    func testRasterize() throws {
        let width = 471, height = 590
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .red)
        bitmap.draw(
            lines:
                QuadraticBezier(cx: 327.0, cy: 295.0, x1: 57.0, y1: 542.0, x2: 190.0, y2: 216.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .white
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
