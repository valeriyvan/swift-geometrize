import XCTest
import SnapshotTesting
@testable import Geometrize

final class LineTests: XCTestCase {

    func testRasterize() throws {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        var lines: [Scanline] = []
        let shift: Double = 10.0
        for x in stride(from: shift, through: Double(width) - shift, by: shift) {
            lines += Line(x1: x, y1: shift, x2: Double(width) - shift, y2: Double(width) - shift)
                .rasterize(x: xRange, y: yRange)
            lines += Line(x1: x, y1: shift, x2: shift, y2: Double(height) - shift)
                .rasterize(x: xRange, y: yRange)
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
    let xRange = 0...width - 1, yRange = 0...height - 1
    let xMaxDouble = Double(width - 1), yMaxDouble = Double(height - 1)
    let tickHeightDouble = Double(tickHeight)
    var lines: [Scanline] = []
    // Horizontal dashed line
    lines += stride(from: 0, through: width, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
            Line(x1: Double(i - step / 5), y1: 0.0, x2: Double(i + step / 5), y2: 0.0)
                .rasterize(x: xRange, y: yRange)
                +
            Line(x1: Double(i - step / 5), y1: yMaxDouble, x2: Double(i + step / 5), y2: yMaxDouble)
                .rasterize(x: xRange, y: yRange)
            return lines
        }
        .flatMap { $0 }
    // Ticks on horizontal line
    lines += stride(from: step, to: width, by: step)
        .map { i -> [Scanline] in
            Line(x1: Double(i), y1: 0.0, x2: Double(i), y2: tickHeightDouble)
                .rasterize(x: xRange, y: yRange)
            +
            Line(x1: Double(i), y1: Double(height - tickHeight - 1), x2: Double(i), y2: yMaxDouble)
                .rasterize(x: xRange, y: yRange)
        }
        .flatMap { $0 }
    // Vertical dashed line
    lines += stride(from: 0, through: height, by: step)
        .map { i -> [Scanline] in
            let lines: [Scanline] =
            Line(x1: 0.0, y1: Double(i - step / 5), x2: 0.0, y2: Double(i + step / 5))
                .rasterize(x: xRange, y: yRange)
            +
            Line(x1: xMaxDouble, y1: Double(i - step / 5), x2: xMaxDouble, y2: Double(i + step / 5))
                .rasterize(x: xRange, y: yRange)
            return lines
        }
        .flatMap { $0 }
    // Ticks on vertical line
    lines += stride(from: step, to: height, by: step)
        .map { i -> [Scanline] in
            Line(x1: 0.0, y1: Double(i), x2: tickHeightDouble, y2: Double(i))
                .rasterize(x: xRange, y: yRange)
            +
            Line(x1: Double(width - tickHeight - 1), y1: Double(i), x2: xMaxDouble, y2: Double(i))
                .rasterize(x: xRange, y: yRange)
        }
        .flatMap { $0 }
    return lines.trimmed(x: xRange, y: yRange)

}
