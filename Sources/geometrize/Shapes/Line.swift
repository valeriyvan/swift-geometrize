import Foundation

public struct Line: Shape {
    public let strokeWidth: Double
    public let x1, y1, x2, y2: Double

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
    }

    public init(strokeWidth: Double, x1: Double, y1: Double, x2: Double, y2: Double) {
        self.strokeWidth = strokeWidth
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Line {
        let range32 = -32...32
        let startingPoint = Point(
            x: Int._random(in: xRange, using: &generator),
            y: Int._random(in: yRange, using: &generator)
        )
        return Line(
            strokeWidth: strokeWidth,
            x1: Double((startingPoint.x + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y1: Double((startingPoint.y + Int._random(in: range32, using: &generator)).clamped(to: yRange)),
            x2: Double((startingPoint.x + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y2: Double((startingPoint.y + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Line {
        let range16 = -16...16
        let newX1, newY1, newX2, newY2: Double
        switch Int._random(in: 0...1, using: &generator) {
        case 0:
            newX1 = Double((Int(x1) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY1 = Double((Int(y1) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newX2 = x2
            newY2 = y2
        case 1:
            newX1 = x1
            newY1 = y1
            newX2 = Double((Int(x2) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY2 = Double((Int(y2) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
        default:
            fatalError("Internal inconsistency")
        }
        return Line(strokeWidth: strokeWidth, x1: newX1, y1: newY1, x2: newX2, y2: newY2)
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        let lines =
            drawThickLine(
                from: Point(x: Int(x1), y: Int(y1)),
                to: Point(x: Int(x2), y: Int(y2)),
                thickness: Int(strokeWidth)
            )
            .compactMap { Scanline(y: $0.y, x1: $0.x, x2: $0.x).trimmed(x: xRange, y: yRange) }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var isDegenerate: Bool {
        x1 == x2 && y1 == y2
    }

    public var description: String {
        "Line(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

}
