import Foundation

public final class Polyline: Shape {
    
    var points: [Point<Double>]
    
    public init() {
        points = []
    }
    
    public init(points: [Point<Double>]) {
        self.points = points
    }
    
    public func copy() -> Polyline {
        Polyline(points: points)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        let startingPoint = Point(
            x: randomRange(min: xMin, max: xMax),
            y: randomRange(min: yMin, max: yMax - 1)
        )
        var points: [Point<Double>] = []
        for _ in 0..<4 {
            points.append(
                Point(
                    x: Double((startingPoint.x + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax - 1)),
                    y: Double((startingPoint.y + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax - 1))
                )
            )
        }
        self.points = points
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        let i = randomRange(min: 0, max: points.count - 1)
        var point = points[i]
        point.x = Double((Int(point.x) + randomRange(min: -64, max:64)).clamped(to: xMin...xMax - 1))
        point.y = Double((Int(point.y) + randomRange(min: -64, max:64)).clamped(to: yMin...yMax - 1))
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
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public func type() -> ShapeType {
        .polyline
    }
    
    public var description: String {
        "Polyline(" + points.map(\.description).joined(separator: ", ") + ")"
    }

}
