import XCTest
import SnapshotTesting
@testable import Geometrize

final class BitmapDownsampleTests: XCTestCase {

    func testBitmapDownsample() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 100.0, ry: 245.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)

        let bitmapDownsampledBy2 = bitmap.downsample(factor: 2)
        assertSnapshot(
            of: bitmapDownsampledBy2,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
