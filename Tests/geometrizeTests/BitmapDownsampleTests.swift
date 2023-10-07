import XCTest
import SnapshotTesting
@testable import Geometrize

final class BitmapDownsampleTests: XCTestCase {

    func testBitmapDownsample() throws {
        let width = 500, height = 500
        let xMax = width - 1, yMax = width - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
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
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)

        let bitmapDownsampledBy2 = bitmap.downsample(factor: 2)
        assertSnapshot(
            matching: bitmapDownsampledBy2,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
