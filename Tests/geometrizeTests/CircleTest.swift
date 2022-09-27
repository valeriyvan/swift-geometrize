import XCTest
import SnapshotTesting
@testable import geometrize

final class CircleTests: XCTestCase {

    override func setUp() {
      super.setUp()
      diffTool = "compare"
    }
    
    func testRasterize() throws {
        let xMax = 500, yMax = 500
        var bitmap = Bitmap(width: xMax, height: yMax, color: .white)
        bitmap.draw(
            lines:
                Circle(x: 250.0, y: 250.0, r: 275.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .red
        )
        bitmap.draw(
            lines:
                Circle(x: 330.0, y: 330.0, r: 250)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Circle(x: 0.0, y: 0.0, r: 133.5)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .blue.withAlphaComponent(128)
        )
        bitmap.draw(
            lines:
                Circle(x: 499.0, y: 0.0, r: 77.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .magenta
        )
        bitmap.draw(
            lines:
                Circle(x: 250.0, y: 250.0, r: 100.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax),
            color:
                .cyan
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 500, step: 100), color: .black)
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}
