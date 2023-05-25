import XCTest
import SnapshotTesting
@testable import Geometrize

final class LineTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let canvasBoundsProvider = { Bounds(xMin: 0, xMax: width, yMin: 0, yMax: height) }
        let xMax = width - 1, yMax = height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        var lines: [Scanline] = []
        let shift: Double = 10.0
        for x in stride(from: shift, through: Double(width) - shift, by: shift) {
            lines += Line(canvasBoundsProvider: canvasBoundsProvider, x1: x, y1: shift, x2: Double(width) - shift, y2: Double(width) - shift)
                        .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            lines += Line(canvasBoundsProvider: canvasBoundsProvider, x1: x, y1: shift, x2: shift, y2: Double(height) - shift)
                        .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
        }
        bitmap.draw(lines: lines, color: .blue)
        bitmap.draw(
            lines:
                scaleScanlinesTrimmed(width: width, height: height, step: 100),
            color:
                .black
        )
        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

}

func scaleScanlinesTrimmed(width: Int, height: Int, step: Int, tickHeight: Int = 5) -> [Scanline] {
    let canvasBoundsProvider = { Bounds(xMin: 0, xMax: width, yMin: 0, yMax: height) }
    let xMax = width - 1, yMax = height - 1
    let xMaxDouble = Double(xMax), yMaxDouble = Double(yMax)
    let tickHeightDouble = Double(tickHeight)
    var lines: [Scanline] = []
    // Horizontal dashed line
    lines += stride(from: 0, through: width, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: Double(i - step / 5), y1: 0.0, x2: Double(i + step / 5), y2: 0.0)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
                +
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: Double(i - step / 5), y1: yMaxDouble, x2: Double(i + step / 5), y2: yMaxDouble)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            return lines
        }
        .flatMap { $0 }
    // Ticks on horizontal line
    lines += stride(from: step, to: width, by: step)
        .map { i -> [Scanline] in
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: Double(i), y1: 0.0, x2: Double(i), y2: tickHeightDouble)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            +
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: Double(i), y1: Double(height - tickHeight - 1), x2: Double(i), y2: yMaxDouble)
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
        }
        .flatMap { $0 }
    // Vertical dashed line
    lines += stride(from: 0, through: height, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: 0.0, y1: Double(i - step / 5), x2: 0.0, y2: Double(i + step / 5))
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            +
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: xMaxDouble, y1: Double(i - step / 5), x2: xMaxDouble, y2: Double(i + step / 5))
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            return lines
        }
        .flatMap { $0 }
    // Ticks on vertical line
    lines += stride(from: step, to: height, by: step)
        .map { i -> [Scanline] in
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: 0.0, y1: Double(i), x2: tickHeightDouble, y2: Double(i))
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            +
            Line(canvasBoundsProvider: canvasBoundsProvider, x1: Double(width - tickHeight - 1), y1: Double(i), x2: xMaxDouble, y2: Double(i))
                .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
        }
        .flatMap { $0 }
    return lines.trimmed(minX: 0, minY: 0, maxX: xMax, maxY: yMax)

}
