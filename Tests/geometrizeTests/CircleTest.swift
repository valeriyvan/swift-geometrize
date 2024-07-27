import XCTest
import SnapshotTesting
@testable import Geometrize

final class CircleTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 250.0, y: 250.0, r: 275.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 330.0, y: 330.0, r: 250)
                .rasterize(x: xRange, y: yRange),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 0.0, y: 0.0, r: 133.5)
                .rasterize(x: xRange, y: yRange),
            color:
                .blue.withAlphaComponent(128)
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 499.0, y: 0.0, r: 77.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .magenta
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 250.0, y: 250.0, r: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .cyan
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
