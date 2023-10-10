import Foundation
import Algorithms

public final class QuadraticBezier: Shape {
    public var x1: Double // First x-coordinate.
    public var y1: Double // First y-coordinate.
    public var x2: Double // Second x-coordinate.
    public var y2: Double // Second y-coordinate.
    public var cx: Double // Control point x-coordinate.
    public var cy: Double // Control point y-coordinate.

    public init() {
        cx = 0.0
        cy = 0.0
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
    }

    public init(cx: Double, cy: Double, x1: Double, y1: Double, x2: Double, y2: Double) {
        self.cx = cx
        self.cy = cy
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public func copy() -> QuadraticBezier {
        QuadraticBezier(cx: cx, cy: cy, x1: x1, y1: y1, x2: x2, y2: y2)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        cx = Double(Int._random(in: rangeX, using: &generator))
        cy = Double(Int._random(in: rangeY, using: &generator))
        x1 = Double(Int._random(in: rangeX, using: &generator))
        y1 = Double(Int._random(in: rangeY, using: &generator))
        x2 = Double(Int._random(in: rangeX, using: &generator))
        y2 = Double(Int._random(in: rangeY, using: &generator))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let range8 = -8...8
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            cx = Double((Int(cx) + Int._random(in: range8, using: &generator)).clamped(to: xMin...xMax))
            cy = Double((Int(cy) + Int._random(in: range8, using: &generator)).clamped(to: yMin...yMax))
        case 1:
            x1 = Double((Int(x1) + Int._random(in: range8, using: &generator)).clamped(to: xMin + 1...xMax))
            y1 = Double((Int(y1) + Int._random(in: range8, using: &generator)).clamped(to: yMin + 1...yMax))
        case 2:
            x2 = Double((Int(x2) + Int._random(in: range8, using: &generator)).clamped(to: xMin + 1...xMax))
            y2 = Double((Int(y2) + Int._random(in: range8, using: &generator)).clamped(to: yMin + 1...yMax))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        let pointCount = 20
        var points: [Point<Int>] = []
        for i in 0...pointCount {
            let t = Double(i) / Double(pointCount)
            let tp = 1.0 - t
            let x: Int = Int(tp * (tp * x1 + t * cx) + t * (tp * cx + t * x2))
            let y: Int = Int(tp * (tp * y1 + t * cy) + t * (tp * cy + t * y2))
            points.append(Point<Int>(x: x, y: y))
        }
        // Prevent scanline overlap, it messes up the energy functions that rely on the scanlines not intersecting themselves
        var duplicates: Set<Point<Int>> = Set()
        for (from, to) in points.adjacentPairs() {
            for point in bresenham(from: from, to: to) {
                if !duplicates.contains(point) {
                    duplicates.insert(point)
                    if let trimmed = Scanline(y: point.y, x1: point.x, x2: point.x).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) {
                        lines.append(trimmed)
                    }
                }
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var description: String {
        "QuadraticBezier(cx=\(cx), cy=\(cy), x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

}
