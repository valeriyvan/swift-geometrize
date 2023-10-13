import XCTest
import PNG
import SnapshotTesting
@testable import Geometrize

final class BresenhamTests: XCTestCase {

    func testBresenham() throws {
        var bitmap = Bitmap(width: 500, height: 400, color: .red.withAlphaComponent(128))
        var points: [Point<Int>] = []
        points.append(contentsOf: drawThickLine(from: Point(x: 50, y: 50), to: Point(x: 450, y: 50)))
        points.append(contentsOf: drawThickLine(from: Point(x: 450, y: 50), to: Point(x: 450, y: 300)))
        points.append(contentsOf: drawThickLine(from: Point(x: 450, y: 300), to: Point(x: 200, y: 350)))
        points.append(contentsOf: drawThickLine(from: Point(x: 200, y: 350), to: Point(x: 475, y: 321)))
        points.append(contentsOf: drawThickLine(from: Point(x: 475, y: 321), to: Point(x: 474, y: 376)))
        points.append(contentsOf: drawThickLine(from: Point(x: 474, y: 376), to: Point(x: 50, y: 350)))
        points.append(contentsOf: drawThickLine(from: Point(x: 50, y: 350), to: Point(x: 50, y: 50)))
        points.forEach { bitmap[$0] = .black }
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 400, step: 100), color: .black)
        assertSnapshot(matching: bitmap, as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image))
    }

    func testBresenhamThickness() throws {
        var bitmap = Bitmap(width: 500, height: 400, color: .red.withAlphaComponent(128))
        var points: [Point<Int>] = []
        points.append(contentsOf: drawThickLine(from: Point(x: 50, y: 50), to: Point(x: 450, y: 50), thickness: 1))
        points.append(contentsOf: drawThickLine(from: Point(x: 450, y: 50), to: Point(x: 450, y: 300), thickness: 2))
        points.append(contentsOf: drawThickLine(from: Point(x: 450, y: 300), to: Point(x: 200, y: 350), thickness: 3))
        points.append(contentsOf: drawThickLine(from: Point(x: 200, y: 350), to: Point(x: 475, y: 321), thickness: 4))
        points.append(contentsOf: drawThickLine(from: Point(x: 475, y: 321), to: Point(x: 474, y: 376), thickness: 5))
        points.append(contentsOf: drawThickLine(from: Point(x: 474, y: 376), to: Point(x: 50, y: 350), thickness: 6))
        points.append(contentsOf: drawThickLine(from: Point(x: 50, y: 350), to: Point(x: 50, y: 50), thickness: 7))
        points.forEach {
            guard bitmap.isInBounds($0) else { return }
            bitmap[$0] = .black
        }
        bitmap.draw(lines: scaleScanlinesTrimmed(width: 500, height: 400, step: 100), color: .black)
        assertSnapshot(matching: bitmap, as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image))
    }

}
