import XCTest
import PNG
import SnapshotTesting

@testable import geometrize

final class BresenhamTests: XCTestCase {

    func testBresenham() throws {
        var bitmap = Bitmap(width: 500, height: 400, color: .red.withAlphaComponent(128))
        var points: [Point<Int>] = []
        points.append(contentsOf: bresenham(from: Point(x: 50, y: 50), to: Point(x: 450, y: 50)))
        points.append(contentsOf: bresenham(from: Point(x: 450, y: 50), to: Point(x: 450, y: 300)))
        points.append(contentsOf: bresenham(from: Point(x: 450, y: 300), to: Point(x: 200, y: 350)))
        points.append(contentsOf: bresenham(from: Point(x: 200, y: 350), to: Point(x: 475, y: 321)))
        points.append(contentsOf: bresenham(from: Point(x: 475, y: 321), to: Point(x: 474, y: 376)))
        points.append(contentsOf: bresenham(from: Point(x: 474, y: 376), to: Point(x: 50, y: 350)))
        points.append(contentsOf: bresenham(from: Point(x: 50, y: 350), to: Point(x: 50, y: 50)))
        points.forEach { bitmap[$0] = .black }
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 400, step: 100), color: .black)
        assertSnapshot(matching: bitmap, as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image))
    }

}
