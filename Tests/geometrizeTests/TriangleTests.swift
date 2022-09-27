import XCTest
import SnapshotTesting
@testable import geometrize

final class TriangleTests: XCTestCase {
    
    func testRasterize() throws {
        let xMax = 500, yMax = 500
        var bitmap = Bitmap(width: xMax, height: yMax, color: .white)
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
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 500, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
