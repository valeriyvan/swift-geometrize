import XCTest
import SnapshotTesting
@testable import Geometrize

final class RotatedEllipseTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                RotatedEllipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 300.0, ry: 100.0, angleDegrees: 30.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .blue.withAlphaComponent(127)
        )
        bitmap.draw(
            lines:
                RotatedEllipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 100.0, ry: 245.0, angleDegrees: 60.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .magenta.withAlphaComponent(127)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)
        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
