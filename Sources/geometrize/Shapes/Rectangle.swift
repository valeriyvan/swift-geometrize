import Foundation

// Represents a rectangle.
public struct Rectangle: Shape {
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

    // Rectangle taking whole size of canvas
    public init(canvasWidth width: Int, height: Int) {
        self.init(strokeWidth: 1, x1: 0.0, y1: 0.0, x2: Double(width), y2: Double(height))
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Rectangle {
        let range32 = 1...32
        return Rectangle(
            strokeWidth: strokeWidth,
            x1: Double(Int._random(in: xRange, using: &generator)),
            y1: Double(Int._random(in: yRange, using: &generator)),
            x2: Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: xRange)),
            y2: Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: yRange))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Rectangle {
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
        return Rectangle(strokeWidth: strokeWidth, x1: newX1, y1: newY1, x2: newX2, y2: newY2)
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        let x1: Int = Int(min(self.x1, self.x2))
        let y1: Int = Int(min(self.y1, self.y2))
        let x2: Int = Int(max(self.x1, self.x2))
        let y2: Int = Int(max(self.y1, self.y2))

        var lines: [Scanline] = []
        for y in y1...y2 {
            let scanline = Scanline(y: y, x1: x1, x2: x2)
            guard let trimmed = scanline.trimmed(x: xRange, y: yRange) else {
                continue
            }
            lines.append(trimmed)
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var cornerPoints: (Point<Double>, Point<Double>, Point<Double>, Point<Double>) {
        (Point<Double>(x: x1, y: y1),
         Point<Double>(x: x2, y: y1),
         Point<Double>(x: x2, y: y2),
         Point<Double>(x: x1, y: y2))
    }

    public var isDegenerate: Bool {
        x1 == x2 || y1 == y2
    }

    public var description: String {
        "Rectangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

}

extension Rectangle: Equatable {

    public static func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
        lhs.x1 == rhs.x1 && lhs.y1 == rhs.y1 && lhs.x2 == rhs.x2 && lhs.y2 == rhs.y2
    }

}
