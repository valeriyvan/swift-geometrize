import XCTest
import SnapshotTesting
@testable import Geometrize

final class TriangleTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xMax = width - 1, yMax = height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Triangle(x1: 20, y1: 20, x2: 480, y2: 300, x3: 100, y3: 480)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .yellow
        )
        bitmap.draw(
            lines:
                Triangle(x1: 510, y1: -10, x2: 250, y2: 505, x3: -5, y3: 270)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
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
