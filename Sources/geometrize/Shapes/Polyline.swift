import Foundation

public final class Polyline: Shape {
    public var points: [Point<Double>]

    public init() {
        points = []
    }

    public init(points: [Point<Double>]) {
        self.points = points
    }

    public func copy() -> Polyline {
        Polyline(points: points)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        let range32 = -32...32
        let startingPoint = Point(
            x: Int._random(in: rangeX, using: &generator),
            y: Int._random(in: rangeY, using: &generator)
        )
        var points: [Point<Double>] = []
        for _ in 0..<4 {
            points.append(
                Point(
                    x: Double((startingPoint.x + Int._random(in: range32, using: &generator)).clamped(to: xMin...xMax)),
                    y: Double((startingPoint.y + Int._random(in: range32, using: &generator)).clamped(to: yMin...yMax))
                )
            )
        }
        self.points = points
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let i = Int._random(in: 0...points.count-1, using: &generator)
        var point = points[i]
        let range64 = -64...64
        point.x = Double((Int(point.x) + Int._random(in: range64, using: &generator)).clamped(to: xMin...xMax))
        point.y = Double((Int(point.y) + Int._random(in: range64, using: &generator)).clamped(to: yMin...yMax))
        points[i] = point
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        // Prevent scanline overlap, it messes up the energy functions that rely on the scanlines not intersecting themselves
        var duplicates: Set<Point<Int>> = Set()
        for i in 0..<points.count {
            let p0 = points[i]
            let p1 = i < points.count - 1 ? points[i + 1] : p0
            let points = bresenham(from: Point<Int>(p0), to: Point<Int>(p1))
            for point in points {
                if !duplicates.contains(point) {
                    duplicates.insert(point)
                    if let trimmed = Scanline(y: point.y, x1: point.x, x2: point.x).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) {
                        lines.append(trimmed)
                    }
                }
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines.")
        }
        return lines
    }

    public var description: String {
        "Polyline(" + points.map(\.description).joined(separator: ", ") + ")"
    }

}
