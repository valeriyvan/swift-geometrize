import XCTest
import SnapshotTesting
@testable import Geometrize

final class LineTests: XCTestCase {

    func testRasterize() throws {
        let xMax = 500, yMax = 500
        var bitmap = Bitmap(width: xMax, height: yMax, color: .white)
        var lines: [Scanline] = []
        let shift: Double = 10.0
        for x in stride(from: shift, through: Double(xMax) - shift, by: shift) {
            lines += Line(x1: x, y1: shift, x2: Double(xMax) - shift, y2: Double(yMax) - shift)
                        .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
            lines += Line(x1: x, y1: shift, x2: shift, y2: Double(yMax) - shift)
                        .rasterize(xMin: 0, yMin: 0, xMax: xMax, yMax: yMax)
        }
        bitmap.draw(lines: lines, color: .blue)
        // scale
        bitmap.draw(
            lines:
                scaleScanlinesTrimmed(width: xMax, height: yMax, step: 100),
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
    var lines: [Scanline] = []
    // Horizontal dashed line
    lines += stride(from: 0, through: width, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
                Line(x1: Double(i - step / 5), y1: 0.0, x2: Double(i + step / 5), y2: 0.0)
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
                +
                Line(x1: Double(i - step / 5), y1: Double(height - 1), x2: Double(i + step / 5), y2: Double(height - 1))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
            return lines
        }
        .flatMap { $0 }
    // Ticks on horizontal line
    lines += stride(from: step, to: width, by: step)
        .map { i -> [Scanline] in
            Line(x1: Double(i), y1: 0.0, x2: Double(i), y2: Double(tickHeight))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
            +
            Line(x1: Double(i), y1: Double(height - tickHeight - 1), x2: Double(i), y2: Double(height - 1))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
        }
        .flatMap { $0 }
    // Vertical dashed line
    lines += stride(from: 0, through: height, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
            Line(x1: 0.0, y1: Double(i - step / 5), x2: 0.0, y2: Double(i + step / 5))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
            +
            Line(x1: Double(width - 1), y1: Double(i - step / 5), x2: Double(width - 1), y2: Double(i + step / 5))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
            return lines
        }
        .flatMap { $0 }
    // Ticks on vertical line
    lines += stride(from: step, to: height, by: step)
        .map { i -> [Scanline] in
            Line(x1: 0.0, y1: Double(i), x2: Double(tickHeight), y2: Double(i))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
            +
            Line(x1: Double(width - tickHeight - 1), y1: Double(i), x2: Double(width - 1), y2: Double(i))
                .rasterize(xMin: 0, yMin: 0, xMax: width, yMax: height)
        }
        .flatMap { $0 }
    return lines.trimmed(minX: 0, minY: 0, maxX: width, maxY: height)

}
