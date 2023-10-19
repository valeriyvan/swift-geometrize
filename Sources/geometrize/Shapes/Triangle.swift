import Foundation

public final class Triangle: Shape {
    public var strokeWidth: Double
    public var x1: Double // First x-coordinate.
    public var y1: Double // First y-coordinate.
    public var x2: Double // Second x-coordinate.
    public var y2: Double // Second y-coordinate.
    public var x3: Double // Third x-coordinate.
    public var y3: Double // Third y-coordinate.

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

    public func copy() -> Triangle {
        Triangle(strokeWidth: strokeWidth, x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3)
    }

    public func setup(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>, using generator: inout SplitMix64) {
        x1 = Double(Int._random(in: xRange, using: &generator))
        y1 = Double(Int._random(in: yRange, using: &generator))
        let range32 = 1...32
        x2 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
        y2 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        x3 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
        y3 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
    }

    public func mutate(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>, using generator: inout SplitMix64) {
        let range32 = -32...32
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            x1 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            y1 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        case 1:
            x2 = Double((Int(x2) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            y2 = Double((Int(y2) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        case 2:
            x3 = Double((Int(x2) + Int._random(in: range32, using: &generator)).clamped(to: xRange))
            y3 = Double((Int(y2) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        default:
            fatalError()
        }
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
