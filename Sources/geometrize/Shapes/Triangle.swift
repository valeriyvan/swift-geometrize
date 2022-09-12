import Foundation

public final class Triangle: Shape {
    
    var x1: Double // First x-coordinate.
    var y1: Double // First y-coordinate.
    var x2: Double // Second x-coordinate.
    var y2: Double // Second y-coordinate.
    var x3: Double // Third x-coordinate.
    var y3: Double // Third y-coordinate.
    
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
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
        x3 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y3 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax - 1))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax - 1))
        case 2:
            x3 = Double((Int(x2) + randomRange(min: -32, max: 32)).clamped(to: xMin...xMax - 1))
            y3 = Double((Int(y2) + randomRange(min: -32, max: 32)).clamped(to: yMin...yMax - 1))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        try! // TODO: !!!
        Polygon(vertices:
            [Point<Int>(x: Int(x1), y: Int(y1)),
             Point<Int>(x: Int(x2), y: Int(y2)),
             Point<Int>(x: Int(x3), y: Int(y3))]
        )
        .scanlines()
        .trimmedScanlines(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
    }
    
    public func type() -> ShapeType {
        .triangle
    }
    
    public var description: String {
        "Triangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2), x3=\(x3), y3=\(y3))"
    }
    
}
