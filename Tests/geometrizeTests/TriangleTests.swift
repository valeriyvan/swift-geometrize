import XCTest
import SnapshotTesting
@testable import Geometrize

final class TriangleTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Triangle(strokeWidth: 1, x1: 20, y1: 20, x2: 480, y2: 300, x3: 100, y3: 480)
                .rasterize(x: xRange, y: yRange),
            color:
                .yellow
        )
        bitmap.draw(
            lines:
                Triangle(strokeWidth: 1, x1: 510, y1: -10, x2: 250, y2: 505, x3: -5, y3: 270)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(128)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
