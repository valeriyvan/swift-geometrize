import Foundation
import Algorithms

public struct QuadraticBezier: Shape {
    public let strokeWidth: Double
    public let x1: Double // First x-coordinate.
    public let y1: Double // First y-coordinate.
    public let x2: Double // Second x-coordinate.
    public let y2: Double // Second y-coordinate.
    public let cx: Double // Control point x-coordinate.
    public let cy: Double // Control point y-coordinate.

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        cx = 0.0
        cy = 0.0
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
    }

    public init(strokeWidth: Double, cx: Double, cy: Double, x1: Double, y1: Double, x2: Double, y2: Double) {
        self.strokeWidth = strokeWidth
        self.cx = cx
        self.cy = cy
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> QuadraticBezier {
        QuadraticBezier(
            strokeWidth: strokeWidth,
            cx: Double(Int._random(in: xRange, using: &generator)),
            cy: Double(Int._random(in: yRange, using: &generator)),
            x1: Double(Int._random(in: xRange, using: &generator)),
            y1: Double(Int._random(in: yRange, using: &generator)),
            x2: Double(Int._random(in: xRange, using: &generator)),
            y2: Double(Int._random(in: yRange, using: &generator))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> QuadraticBezier {
        let range8 = -8...8
        let newX1, newY1, newX2, newY2, newCx, newCy: Double
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            newX1 = x1
            newY1 = y1
            newX2 = x2
            newY2 = y2
            newCx = Double((Int(cx) + Int._random(in: range8, using: &generator))
                    .clamped(to: xRange))
            newCy = Double((Int(cy) + Int._random(in: range8, using: &generator))
                    .clamped(to: yRange))
        case 1:
            newX1 = Double((Int(x1) + Int._random(in: range8, using: &generator))
                    .clamped(to: xRange.lowerBound + 1...xRange.upperBound))
            newY1 = Double((Int(y1) + Int._random(in: range8, using: &generator))
                    .clamped(to: yRange.lowerBound + 1...yRange.upperBound))
            newX2 = x2
            newY2 = y2
            newCx = cx
            newCy = cy
        case 2:
            newX1 = x1
            newY1 = y1
            newX2 = Double((Int(x2) + Int._random(in: range8, using: &generator))
                    .clamped(to: xRange.lowerBound + 1...xRange.upperBound))
            newY2 = Double((Int(y2) + Int._random(in: range8, using: &generator))
                    .clamped(to: yRange.lowerBound + 1...yRange.upperBound))
            newCx = cx
            newCy = cy
        default:
            fatalError("Internal inconsistency")
        }
        return QuadraticBezier(
            strokeWidth: strokeWidth,
            cx: newCx,
            cy: newCy,
            x1: newX1,
            y1: newY1,
            x2: newX2,
            y2: newY2
        )
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        var lines: [Scanline] = []
        let pointCount = 20
        var points: [Point<Int>] = []
        points.reserveCapacity(pointCount)
        for i in 0...pointCount {
            let t = Double(i) / Double(pointCount)
            let tp = 1.0 - t
            let x: Int = Int(tp * (tp * x1 + t * cx) + t * (tp * cx + t * x2))
            let y: Int = Int(tp * (tp * y1 + t * cy) + t * (tp * cy + t * y2))
            points.append(Point<Int>(x: x, y: y))
        }
        // Prevent scanline overlap because it messes up the energy functions
        // that rely on the scanlines not intersecting themselves
        var duplicates: Set<Point<Int>> = Set()
        for (from, to) in points.adjacentPairs() {
            for pnt in drawThickLine(from: from, to: to, thickness: Int(strokeWidth)) where !duplicates.contains(pnt) {
                duplicates.insert(pnt)
                if let trimmed = Scanline(y: pnt.y, x1: pnt.x, x2: pnt.x).trimmed(x: xRange, y: yRange) {
                    lines.append(trimmed)
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
