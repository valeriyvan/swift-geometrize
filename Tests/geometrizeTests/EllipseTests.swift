import XCTest
import SnapshotTesting
@testable import Geometrize

final class EllipseTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let canvasBoundsProvider = { Bounds(xMin: 0, xMax: width, yMin: 0, yMax: height) }
        let xMax = width - 1, yMax = width - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(canvasBoundsProvider: canvasBoundsProvider, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .red.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Ellipse(canvasBoundsProvider: canvasBoundsProvider, x: 250.0, y: 250.0, rx: 100.0, ry: 245.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
