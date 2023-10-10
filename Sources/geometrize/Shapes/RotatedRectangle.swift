import Foundation

/// Represents a rotated rectangle.
public final class RotatedRectangle: Shape {
    public var x1: Double
    public var y1: Double
    public var x2: Double
    public var y2: Double
    public var angleDegrees: Double

    public required init() {
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        angleDegrees = 0.0
    }

    public init(x1: Double, y1: Double, x2: Double, y2: Double, angleDegrees: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.angleDegrees = angleDegrees
    }

    public func copy() -> RotatedRectangle {
        RotatedRectangle(x1: x1, y1: y1, x2: x2, y2: y2, angleDegrees: angleDegrees)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        x1 = Double(Int._random(in: rangeX, using: &generator))
        y1 = Double(Int._random(in: rangeY, using: &generator))
        let range32 = 1...32
        x2 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: rangeX))
        y2 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: rangeY))
        angleDegrees = Double(Int._random(in: 0...360, using: &generator))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        let range16 = -16...16
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            x1 = Double((Int(x1) + Int._random(in: range16, using: &generator)).clamped(to: rangeX))
            y1 = Double((Int(y1) + Int._random(in: range16, using: &generator)).clamped(to: rangeY))
        case 1:
            x2 = Double((Int(x2) + Int._random(in: range16, using: &generator)).clamped(to: rangeX))
            y2 = Double((Int(y2) + Int._random(in: range16, using: &generator)).clamped(to: rangeY))
        case 2:
            angleDegrees = Double((Int(angleDegrees) + Int._random(in: -4...4, using: &generator)).clamped(to: 0...360))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        let cornerPoints = cornerPoints
        let vertices = [
            Point<Int>(cornerPoints.0),
            Point<Int>(cornerPoints.1),
            Point<Int>(cornerPoints.2),
            Point<Int>(cornerPoints.3)
        ]
        guard let polygon = try? Polygon(vertices: vertices) else {
            print("Warning: \(#function) produced no scanlines.")
            return []
        }
        let lines = polygon.scanlines()
            .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines.")
        }
        return lines
    }

    public var cornerPoints: (Point<Double>, Point<Double>, Point<Double>, Point<Double>) {
        let xx1 = min(x1, x2)
        let xx2 = max(x1, x2)
        let yy1 = min(y1, y2)
        let yy2 = max(y1, y2)

        let cx = (xx2 + xx1) / 2.0
        let cy = (yy2 + y1) / 2.0

        let ox1 = xx1 - cx
        let ox2 = xx2 - cx
        let oy1 = yy1 - cy
        let oy2 = yy2 - cy

        let rads = angleDegrees * .pi / 180.0
        let c = cos(rads)
        let s = sin(rads)

        let ul = Point<Double>(x: ox1 * c - oy1 * s + cx, y: ox1 * s + oy1 * c + cy)
        let bl = Point<Double>(x: ox1 * c - oy2 * s + cx, y: ox1 * s + oy2 * c + cy)
        let ur = Point<Double>(x: ox2 * c - oy1 * s + cx, y: ox2 * s + oy1 * c + cy)
        let br = Point<Double>(x: ox2 * c - oy2 * s + cx, y: ox2 * s + oy2 * c + cy)

        return (ul, ur, br, bl)
    }

    public var isDegenerate: Bool {
        x1 == x2 || y1 == y2
    }

    public var description: String {
        "RotatedRectangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2)), angleDegrees=\(angleDegrees))"
    }

}
