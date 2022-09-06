import Foundation

var canvasBounds: (xMin: Int, yMin: Int, xMax: Int, yMax: Int) = (0, 0, .max, .max)

// Specifies the types of shapes that can be used.
// These can be combined to produce images composed of multiple primitive types.
// TODO: put it inside Shape. Or remove completely.
enum ShapeType: String, CaseIterable {
    case rectangle
    case rotatedRectangle
    case triangle
    case ellipse
    case rotatedEllipse
    case circle
    case line
    case quadraticBezier
    case polyline
    case shapeCount
}

protocol Shape: AnyObject, CustomStringConvertible {
    init()
    
    func copy() -> Self
    
    func setup()
    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int);

    func mutate()
    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int);

    func rasterize() -> [Scanline]
    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline];

    func type() -> ShapeType
}

extension Shape {

    func setup() {
        setup(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

    func mutate() {
        mutate(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

    func rasterize() -> [Scanline] {
        rasterize(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

}


func ==(lhs: any Shape, rhs: any Shape) -> Bool {
    switch (lhs, rhs) {
    case (let lhs as Rectangle, let rhs as Rectangle): return lhs == rhs
    default: return false
    }
}

// Represents a rectangle.
final class Rectangle: Shape {
    var x1, y1, x2, y2: Double
    
    required init() {
        x1 = 0
        y1 = 0
        x2 = 0
        y2 = 0
    }
    
    init(x1: Double, y1: Double, x2: Double, y2: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    func copy() -> Rectangle {
        let aCopy = Rectangle(x1: x1, y1: y1, x2: x2, y2: y2)
        return aCopy
    }
    
    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
    }

    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        print("Enter mutate Rectangle(x1:\(x1),y1:\(y1),x2:\(x2),y2:\(y2))")
        switch randomRange(min: 0, max: 1) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        default:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        }
        print("Exit mutate Rectangle(x1:\(x1),y1:\(y1),x2:\(x2),y2:\(y2))")
    }

    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        print("Enter rasterize Rectangle(x1:\(x1),y1:\(y1),x2:\(x2),y2:\(y2))")
        let x1: Int = Int(min(self.x1, self.x2))
        let y1: Int = Int(min(self.y1, self.y2))
        let x2: Int = Int(max(self.x1, self.x2))
        let y2: Int = Int(max(self.y1, self.y2))

        var lines: [Scanline] = []
        for y in y1...y2 {
            let scanline = Scanline(y: y, x1: x1, x2: x2)
            guard let trimmed = scanline.trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) else { continue
            }
            lines.append(trimmed)
        }
        return lines
    }

    func type() -> ShapeType {
        .rectangle
    }
    
    var description: String {
        "Rectangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2))"
    }

}

extension Rectangle: Equatable {
    
    static func == (lhs: Rectangle, rhs: Rectangle) -> Bool {
        lhs.x1 == rhs.x1 && lhs.y1 == rhs.y1 && lhs.x2 == rhs.x2 && lhs.y2 == rhs.y2
    }
    
}

// Represents a rotated rectangle.
final class RotatedRectangle: Shape {
    
    var x1: Double
    var y1: Double
    var x2: Double
    var y2: Double
    var angle: Double

    required init() {
        x1 = 0.0
        y1 = 0.0
        x2 = 0.0
        y2 = 0.0
        angle = 0.0
    }
    
    init(x1: Double, y1: Double, x2: Double, y2: Double, angle: Double) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.angle = angle
    }

    func copy() -> RotatedRectangle {
        let aCopy = RotatedRectangle(x1: x1, y1: y1, x2: x2, y2: y2, angle: angle)
        return aCopy
    }
    
    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
        angle = Double(randomRange(min: 0, max: 360))
    }

    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 2) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 1:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 2:
            angle = Double((Int(angle) + randomRange(min: -4, max: 4)).clamped(to: 0...360))
        default:
            fatalError()
        }
    }

    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        let cornerPoints = cornerPoints
        let lines = try! Polygon(vertices: [Point<Int>(cornerPoints.0), Point<Int>(cornerPoints.1), Point<Int>(cornerPoints.2), Point<Int>(cornerPoints.3)]).scanlines()
        return lines.trimmedScanlines(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
    }

    var cornerPoints: (Point<Double>, Point<Double>, Point<Double>, Point<Double>) {
        let _x1 = min(x1, x2)
        let _x2 = max(x1, x2)
        let _y1 = min(y1, y2)
        let _y2 = max(y1, y2)

        let cx = (_x2 + _x1) / 2.0
        let cy = (_y2 + y1) / 2.0

        let ox1 = _x1 - cx
        let ox2 = _x2 - cx
        let oy1 = _y1 - cy
        let oy2 = _y2 - cy

        let rads = angle * .pi / 180.0
        let c = cos(rads)
        let s = sin(rads)

        let ul = Point<Double>(x: ox1 * c - oy1 * s + cx, y: ox1 * s + oy1 * c + cy)
        let bl = Point<Double>(x: ox1 * c - oy2 * s + cx, y: ox1 * s + oy2 * c + cy)
        let ur = Point<Double>(x: ox2 * c - oy1 * s + cx, y: ox2 * s + oy1 * c + cy)
        let br = Point<Double>(x: ox2 * c - oy2 * s + cx, y: ox2 * s + oy2 * c + cy)

        return (ul, ur, br, bl)
    }
    
    func type() -> ShapeType {
        .rotatedRectangle
    }
    
    var description: String {
        "RotatedRectangle(x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2)), angle=\(angle)"
    }
    
}

struct Point<SignedInteger> {
    var x, y: SignedInteger
}

extension Point<Int> {
    init(_ p: Point<Double>) {
        x = Int(p.x)
        y = Int(p.y)
    }
}

struct Polygon<N: SignedInteger> {
    var vertices: [Point<N>]
    
    init(vertices: [Point<N>]) throws {
        guard vertices.count > 2 else {
            fatalError("Polygon should have more than 2 vertices")
        }
        // TODO: check if vertices really form a polygon
        self.vertices = vertices
    }
    
    init(vertices v: (Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2]
    }
    
    init(vertices v: (Point<N>, Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2, v.3]

    }
    
    init(vertices v: (Point<N>, Point<N>, Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2, v.3, v.4]
    }
}

extension Polygon {
    
    func scanlines() -> [Scanline] {
        var edges = [Point<N>]()
        for i in vertices.indices {
            let p1 = vertices[i]
            let p2 = i == vertices.count - 1 ? vertices[0] : vertices[i + 1]
            let p1p2 = bresenham(from: p1, to: p2)
            edges.append(contentsOf: p1p2)
        }
        // Convert outline to scanlines
        var yToXs = [N: Set<N>]()
        for point in edges {
            yToXs[point.y, default: Set()].insert(point.x)
        }
        var lines: [Scanline] = [Scanline]()
        for (y, xs) in yToXs {
            let xMin = xs.min()! // TODO: let (xMin, xMax) = xs.minAndMax()!
            let xMax = xs.max()!
            let line = Scanline(y: Int(y), x1: Int(xMin), x2: Int(xMax))
            lines.append(line)
        }
        return lines
    }
}

func bresenham<N: SignedInteger>(from: Point<N>, to: Point<N>) -> [Point<N>] {
    var dx = to.x - from.x
    let ix: N = (dx > 0 ? 1 : 0) - (dx < 0 ? 1 : 0)
    dx = abs(dx) << 1
    var dy = to.y - from.y
    let iy: N = (dy > 0 ? 1 : 0) - (dy < 0 ? 1 : 0)
    dy = abs(dy) << 1
    var points: [Point<N>] = [from]
    var from = from
    if dx >= dy {
        var error = dy - (dx >> 1)
        while from.x != to.x {
            if error >= 0 && (error != 0 || ix > 0) {
                error -= dx;
                from.y += iy
            }

            error += dy
            from.x += ix
            
            points.append(from)
        }
    } else {
        var error = dx - (dy >> 1)
        while from.y != to.y {
            if error >= 0 && (error != 0 || (iy > 0)) {
                error -= dy
                from.x += ix
            }

            error += dx
            from.y += iy

            points.append(from)
        }
    }
    return points
}
