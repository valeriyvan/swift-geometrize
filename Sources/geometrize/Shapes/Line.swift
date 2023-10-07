import Foundation

public final class Line: Shape {
    public var x1, y1, x2, y2: Double

    public init() {
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

    public func copy() -> Line {
        Line(x1: x1, y1: y1, x2: x2, y2: y2)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let rangeX = xMin...xMax
        let rangeY = yMin...yMax
        let range32 = -32...32
        let startingPoint = Point(
            x: Int._random(in: rangeX, using: &generator),
            y: Int._random(in: rangeY, using: &generator)
        )
        x1 = Double(startingPoint.x + Int._random(in: range32, using: &generator).clamped(to: rangeX))
        y1 = Double(startingPoint.y + Int._random(in: range32, using: &generator).clamped(to: rangeY))
        x2 = Double(startingPoint.x + Int._random(in: range32, using: &generator).clamped(to: rangeX))
        y2 = Double(startingPoint.y + Int._random(in: range32, using: &generator).clamped(to: rangeY))
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
        let lines =
            bresenham(from: Point(x: Int(x1), y: Int(y1)), to: Point(x: Int(x2), y: Int(y2)))
            .compactMap {
                Scanline(y: $0.y, x1: $0.x, x2: $0.x)
                .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
            }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public func type() -> ShapeType {
        .line
    }

    public var isDegenerate: Bool {
        x1 == x2 && y1 == y2
    }

    public var description: String {
        "Line(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

}
