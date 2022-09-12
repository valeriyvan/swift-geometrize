import Foundation

public final class Circle: Shape {
    
    var x: Double // x-coordinate.
    var y: Double // y-coordinate.
    var r: Double // Radius.
    
    public init() {
        x = 0.0
        y = 0.0
        r = 0.0
    }
    
    public init(x: Double, y: Double, r: Double) {
        self.x = x
        self.y = y
        self.r = r
    }
    
    public func copy() -> Circle {
        Circle(x: x, y: y, r: r)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x = Double(randomRange(min: xMin, max: xMax - 1))
        y = Double(randomRange(min: yMin, max: yMax - 1))
        r = Double(randomRange(min: 1, max: 32))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 1) {
        case 0:
            let range = xMin...xMax - 1
            x = Double((Int(x) + randomRange(min: -16, max: 16)).clamped(to: range))
            y = Double((Int(y) + randomRange(min: -16, max: 16)).clamped(to: range))
        case 1:
            r = Double((Int(r) + randomRange(min: -16, max: 16)).clamped(to: 1...xMax - 1)) // clamp incorect
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        let r = Int(r)
        for y in -r...r {
            var xScan: [Int] = []
            for x in -r...r where x * x + y * y <= r * r {
                xScan.append(x)
            }
            guard let xScanFirst = xScan.first, let xScanLast = xScan.last else { continue }
            let fy = Int(self.y) + y
            let range = xMin...xMax - 1
            let x1 = (Int(x) + xScanFirst).clamped(to: range)
            let x2 = (Int(x) + xScanLast).clamped(to: range)
            lines.append(Scanline(y: fy, x1: x1, x2: x2))
        }
        return lines.trimmedScanlines(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
    }

    public func type() -> ShapeType {
        .circle
    }
    
    public var description: String {
        "Circle(x=\(x), y=\(y), r=\(r))"
    }

}
