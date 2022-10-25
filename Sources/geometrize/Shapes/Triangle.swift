import Foundation

public final class Triangle: Shape {

    public var x1: Double // First x-coordinate.
    public var y1: Double // First y-coordinate.
    public var x2: Double // Second x-coordinate.
    public var y2: Double // Second y-coordinate.
    public var x3: Double // Third x-coordinate.
    public var y3: Double // Third y-coordinate.

    public init() {
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        x3 = 0.0
        y3 = 0.0
    }

    public init(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.x3 = x3
        self.y3 = y3
    }

    public func copy() -> Triangle {
        Triangle(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x1 = Double(randomRange(min: xMin, max: xMax))
        y1 = Double(randomRange(min: yMin, max: yMax))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax))
        x3 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax))
        y3 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax))
            y1 = Double((Int(y1) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax))
            y2 = Double((Int(y2) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax))
        case 2:
            x3 = Double((Int(x2) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax))
            y3 = Double((Int(y2) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
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
            .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines.")
        }
        return lines
    }

    public func type() -> ShapeType {
        .triangle
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
