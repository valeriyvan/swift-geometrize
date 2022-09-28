import Foundation

// Represents a rotated rectangle.
public final class RotatedRectangle: Shape {
    
    public var x1: Double
    public var y1: Double
    public var x2: Double
    public var y2: Double
    public var angle: Double

    public required init() {
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        angle = 0.0
    }
    
    public init(x1: Double, y1: Double, x2: Double, y2: Double, angle: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.angle = angle
    }

    public func copy() -> RotatedRectangle {
        RotatedRectangle(x1: x1, y1: y1, x2: x2, y2: y2, angle: angle)
    }
    
    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
        angle = Double(randomRange(min: 0, max: 360))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 2:
            angle = Double((Int(angle) + randomRange(min: -4, max: 4)).clamped(to: 0...360))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        let cornerPoints = cornerPoints
        let lines = try! Polygon(vertices: [Point<Int>(cornerPoints.0), Point<Int>(cornerPoints.1), Point<Int>(cornerPoints.2), Point<Int>(cornerPoints.3)]).scanlines()
            .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var cornerPoints: (Point<Double>, Point<Double>, Point<Double>, Point<Double>) {
        let _x1 = min(x1, x2)
        let _x2 = max(x1, x2)
        let _y1 = min(y1, y2)
        let _y2 = max(y1, y2)

        let cx = (_x2 + _x1) / 2.0
        let cy = (_y2 + y1) / 2.0

        let ox1 = _x1 - cx
        let ox2 = _x2 - cx
        let oy1 = _y1 - cy
        let oy2 = _y2 - cy

        let rads = angle * .pi / 180.0
        let c = cos(rads)
        let s = sin(rads)

        let ul = Point<Double>(x: ox1 * c - oy1 * s + cx, y: ox1 * s + oy1 * c + cy)
        let bl = Point<Double>(x: ox1 * c - oy2 * s + cx, y: ox1 * s + oy2 * c + cy)
        let ur = Point<Double>(x: ox2 * c - oy1 * s + cx, y: ox2 * s + oy1 * c + cy)
        let br = Point<Double>(x: ox2 * c - oy2 * s + cx, y: ox2 * s + oy2 * c + cy)

        return (ul, ur, br, bl)
    }
    
    public func type() -> ShapeType {
        .rotatedRectangle
    }
    
    public var isDegenerate: Bool {
        x1 == x2 || y1 == y2
    }

    public var description: String {
        "RotatedRectangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2)), angle=\(angle))"
    }
    
}
