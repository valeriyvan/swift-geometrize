import XCTest
import SnapshotTesting
@testable import Geometrize

final class PolylineTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        
        bitmap.draw(
            lines:
                Polyline(strokeWidth: 1, points: [
                    Point(x: 50.0, y: 100.0),
                    Point(x: 200.0, y: 50.0),
                    Point(x: 350.0, y: 150.0),
                    Point(x: 450.0, y: 100.0)
                ])
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(200)
        )
        
        bitmap.draw(
            lines:
                Polyline(strokeWidth: 1, points: [
                    Point(x: 100.0, y: 200.0),
                    Point(x: 150.0, y: 300.0),
                    Point(x: 250.0, y: 350.0),
                    Point(x: 400.0, y: 300.0),
                    Point(x: 450.0, y: 250.0)
                ])
                .rasterize(x: xRange, y: yRange),
            color:
                .green.withAlphaComponent(200)
        )
        
        bitmap.draw(
            lines:
                Polyline(strokeWidth: 1, points: [
                    Point(x: 150.0, y: 400.0),
                    Point(x: 250.0, y: 450.0),
                    Point(x: 350.0, y: 400.0),
                    Point(x: 300.0, y: 350.0),
                    Point(x: 200.0, y: 350.0),
                    Point(x: 150.0, y: 400.0)
                ])
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
