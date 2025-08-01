import XCTest
import SnapshotTesting
@testable import Geometrize

final class RotatedRectangleTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 300
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                RotatedRectangle(strokeWidth: 1, x1: 20.0, y1: 20.0, x2: 480.0, y2: 280.0, angleDegrees: 0.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .yellow.withAlphaComponent(110)
        )
        bitmap.draw(
            lines:
                RotatedRectangle(strokeWidth: 1, x1: 50.0, y1: 50.0, x2: 450.0, y2: 200.0, angleDegrees: 30.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                RotatedRectangle(strokeWidth: 1, x1: 100.0, y1: 250.0, x2: 400.0, y2: 450.0, angleDegrees: 60.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                RotatedRectangle(strokeWidth: 1, x1: 200.0, y1: 150.0, x2: 300.0, y2: 350.0, angleDegrees: 45.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .blue.withAlphaComponent(128)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
