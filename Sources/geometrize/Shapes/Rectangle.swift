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

    public func copy() -> Rectangle {
        Rectangle(x1: x1, y1: y1, x2: x2, y2: y2)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x1 = Double(randomRange(min: xMin, max: xMax))
        y1 = Double(randomRange(min: yMin, max: yMax))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 1) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax))
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

    public func type() -> ShapeType {
        .rectangle
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
