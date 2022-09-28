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

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        let startingPoint = Point(
            x: randomRange(min: xMin, max: xMax),
            y: randomRange(min: yMin, max: yMax - 1)
        )
        let rangeX = xMin...xMax - 1
        let rangeY = yMin...yMax - 1
        x1 = Double(startingPoint.x + randomRange(min: -32, max: 32).clamped(to: rangeX))
        y1 = Double(startingPoint.y + randomRange(min: -32, max: 32).clamped(to: rangeY))
        x2 = Double(startingPoint.x + randomRange(min: -32, max: 32).clamped(to: rangeX))
        y2 = Double(startingPoint.y + randomRange(min: -32, max: 32).clamped(to: rangeY))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        let rangeX = xMin...xMax - 1
        let rangeY = yMin...yMax - 1
        switch randomRange(min: 0, max: 1) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: rangeX))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: rangeY))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: rangeX))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: rangeY))
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
