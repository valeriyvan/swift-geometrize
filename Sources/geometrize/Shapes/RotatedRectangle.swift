import Foundation

/// Represents a rotated rectangle.
public struct RotatedRectangle: Shape {
    public let strokeWidth: Double
    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double
    public let angleDegrees: Double

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        angleDegrees = 0.0
    }

    public init(strokeWidth: Double, x1: Double, y1: Double, x2: Double, y2: Double, angleDegrees: Double) {
        self.strokeWidth = strokeWidth
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.angleDegrees = angleDegrees
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> RotatedRectangle {
        let range32 = 1...32
        return RotatedRectangle(
            strokeWidth: strokeWidth,
            x1: Double(Int._random(in: xRange, using: &generator)),
            y1: Double(Int._random(in: yRange, using: &generator)),
            x2: Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y2: Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange)),
            angleDegrees: Double(Int._random(in: 0...360, using: &generator))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> RotatedRectangle {
        let range16 = -16...16
        let newX1, newY1, newX2, newY2, newAngleDegrees: Double
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            newX1 = Double((Int(x1) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY1 = Double((Int(y1) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newX2 = x2
            newY2 = y2
            newAngleDegrees = angleDegrees
        case 1:
            newX1 = x1
            newY1 = y1
            newX2 = Double((Int(x2) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY2 = Double((Int(y2) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newAngleDegrees = angleDegrees
        case 2:
            newX1 = x1
            newY1 = y1
            newX2 = x2
            newY2 = y2
            newAngleDegrees = Double((Int(angleDegrees) + Int._random(in: -4...4, using: &generator))
                .clamped(to: 0...360))
        default:
            fatalError("Internal inconsistency")
        }
        return RotatedRectangle(
            strokeWidth: strokeWidth,
            x1: newX1,
            y1: newY1,
            x2: newX2,
            y2: newY2,
            angleDegrees: newAngleDegrees
        )
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
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
            .trimmed(x: xRange, y: yRange)
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
