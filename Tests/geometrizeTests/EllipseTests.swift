import XCTest
import SnapshotTesting
@testable import geometrize

final class EllipseTests: XCTestCase {

    func testRasterize() throws {
        let xMax = 500, yMax = 500
        var bitmap = Bitmap(width: xMax, height: yMax, color: .white)
        bitmap.draw(
            lines:
                Ellipse(x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .red.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Ellipse(x: 250.0, y: 250.0, rx: 100.0, ry: 245.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 500, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
