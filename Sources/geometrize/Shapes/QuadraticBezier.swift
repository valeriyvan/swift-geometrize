import Foundation

public final class QuadraticBezier: Shape {

    var cx: Double // Control point x-coordinate.
    var cy: Double // Control point y-coordinate.
    var x1: Double // First x-coordinate.
    var y1: Double // First y-coordinate.
    var x2: Double // Second x-coordinate.
    var y2: Double // Second y-coordinate.

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

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        cx = Double(randomRange(min: xMin, max: xMax - 1))
        cy = Double(randomRange(min: yMin, max: yMax - 1))
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double(randomRange(min: xMin, max: xMax - 1))
        y2 = Double(randomRange(min: yMin, max: yMax - 1))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            cx = Double((Int(cx) + randomRange(min: -8, max: 8)).clamped(to: xMin...xMax - 1))
            cy = Double((Int(cy) + randomRange(min: -8, max: 8)).clamped(to: yMin...yMax - 1))
        case 1:
            // NOTE +1 on the minimum values for paranoia reasons as I wrote it that way originally, not sure if it's needed
            x1 = Double((Int(x1) + randomRange(min: -8, max: 8)).clamped(to: xMin + 1...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -8, max: 8)).clamped(to: yMin + 1...yMax - 1))
        case 2:
            // NOTE +1 on the minimum values for paranoia reasons as I wrote it that way originally, not sure if it's needed
            x2 = Double((Int(x2) + randomRange(min: -8, max: 8)).clamped(to: xMin + 1...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -8, max: 8)).clamped(to: yMin + 1...yMax - 1))
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
        for i in 0..<points.count - 1 { // TODO: enumerate pairs
            let points = bresenham(from: points[i], to: points[i + 1])
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
        .quadraticBezier
    }
    
    public var description: String {
        "QuadraticBezier(cx=\(cx), cy=\(cy), x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

    
}
