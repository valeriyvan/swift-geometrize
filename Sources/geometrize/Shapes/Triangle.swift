import Foundation

public struct Triangle: Shape {
    public let strokeWidth: Double
    public let x1: Double // First x-coordinate.
    public let y1: Double // First y-coordinate.
    public let x2: Double // Second x-coordinate.
    public let y2: Double // Second y-coordinate.
    public let x3: Double // Third x-coordinate.
    public let y3: Double // Third y-coordinate.

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        x3 = 0.0
        y3 = 0.0
    }

    public init(strokeWidth: Double, x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) {
        self.strokeWidth = strokeWidth
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.x3 = x3
        self.y3 = y3
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Triangle {
        let range32 = 1...32
        return Triangle(
            strokeWidth: strokeWidth,
            x1: Double(Int._random(in: xRange, using: &generator)),
            y1: Double(Int._random(in: yRange, using: &generator)),
            x2: Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y2: Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange)),
            x3: Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y3: Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Triangle {
        let range32 = -32...32
        let newX1, newY1, newX2, newY2, newX3, newY3: Double
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            newX1 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            newY1 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
            newX2 = x2
            newY2 = y2
            newX3 = x3
            newY3 = y3
        case 1:
            newX1 = x1
            newY1 = y1
            newX2 = Double((Int(x2) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            newY2 = Double((Int(y2) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
            newX3 = x3
            newY3 = y3
        case 2:
            newX1 = x1
            newY1 = y1
            newX2 = x2
            newY2 = y2
            newX3 = Double((Int(x2) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            newY3 = Double((Int(y2) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        default:
            fatalError("Internal inconsistency")
        }
        return Triangle(strokeWidth: strokeWidth, x1: newX1, y1: newY1, x2: newX2, y2: newY2, x3: newX3, y3: newY3)
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        let vertices = [
            Point<Int>(x: Int(x1), y: Int(y1)),
            Point<Int>(x: Int(x2), y: Int(y2)),
            Point<Int>(x: Int(x3), y: Int(y3))
        ]
        guard let polygon = try? Polygon(vertices: vertices) else {
            print("Warning: \(#function) produced no scanlines.")
            return []
        }
        let lines = polygon
            .scanlines()
            .trimmed(x: xRange, y: yRange)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines.")
        }
        return lines
    }

    public var isDegenerate: Bool {
        x1 == x2 && y1 == y2 ||
        x1 == x3 && y1 == y3 ||
        x2 == x3 && y2 == y3
    }

    public var description: String {
        "Triangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2), x3=\(x3), y3=\(y3))"
    }

}
