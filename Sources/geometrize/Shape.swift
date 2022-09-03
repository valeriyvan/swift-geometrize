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
