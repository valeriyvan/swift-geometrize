import Foundation

// Represents a rectangle.
public final class Rectangle: Shape {
    public var x1, y1, x2, y2: Double

    required public init() {
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
    }

    public init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    // Rectangle taking whole size of canvas
    public convenience init(canvasWidth width: Int, height: Int) {
        self.init(x1: 0.0, y1: 0.0, x2: Double(width), y2: Double(height))
    }

    public func copy() -> Rectangle {
        Rectangle(x1: x1, y1: y1, x2: x2, y2: y2)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        let range32 = 1...32
        x1 = Double(Int._random(in: rangeX, using: &generator))
        y1 = Double(Int._random(in: rangeY, using: &generator))
        x2 = Double((Int(x1) + Int._random(in: range32, using: &generator)).clamped(to: rangeX))
        y2 = Double((Int(y1) + Int._random(in: range32, using: &generator)).clamped(to: rangeY))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        let range16 = -16...16
        switch Int._random(in: 0...1, using: &generator) {
        case 0:
            x1 = Double((Int(x1) + Int._random(in: range16, using: &generator)).clamped(to: rangeX))
            y1 = Double((Int(y1) + Int._random(in: range16, using: &generator)).clamped(to: rangeY))
        case 1:
            x2 = Double((Int(x2) + Int._random(in: range16, using: &generator)).clamped(to: rangeX))
            y2 = Double((Int(y2) + Int._random(in: range16, using: &generator)).clamped(to: rangeY))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        let x1: Int = Int(min(self.x1, self.x2))
        let y1: Int = Int(min(self.y1, self.y2))
        let x2: Int = Int(max(self.x1, self.x2))
        let y2: Int = Int(max(self.y1, self.y2))

        var lines: [Scanline] = []
        for y in y1...y2 {
            let scanline = Scanline(y: y, x1: x1, x2: x2)
            guard let trimmed = scanline.trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) else {
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
