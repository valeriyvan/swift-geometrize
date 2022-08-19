import Foundation

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
    func setup()
    func mutate()
    func rasterize() -> [Scanline]
    func type() -> ShapeType
    
    var xMin: Int { get set }
    var yMin: Int { get set }
    var xMax: Int { get set }
    var yMax: Int { get set }
}

// Represents a rectangle.

class Rectangle: Shape {
    var xMin: Int = 0
    
    var yMin: Int = 0
    
    var xMax: Int = 1
    
    var yMax: Int = 1
    
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
    
    func setup() {
        print(#function)
        x1 = Double(randomRange(min: xMin, max: xMax - 1))
        y1 = Double(randomRange(min: yMin, max: yMax - 1))
        x2 = Double((Int(x1) + randomRange(min: 1, max: 32)).clamped(to: xMin...xMax - 1))
        y2 = Double((Int(y1) + randomRange(min: 1, max: 32)).clamped(to: yMin...yMax - 1))
    }

    func mutate() {
        print(#function)
        switch randomRange(min: 0, max: 1) {
        case 0:
            x1 = Double((Int(x1) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y1 = Double((Int(y1) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        default:
            x2 = Double((Int(x2) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y2 = Double((Int(y2) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        }
    }

    func rasterize() -> [Scanline] {
        print(#function)
        let x1: Int = Int(min(self.x1, self.x2))
        let y1: Int = Int(min(self.y1, self.y2))
        let x2: Int = Int(max(self.x1, self.x2))
        let y2: Int = Int(max(self.y1, self.y2))

        var lines: [Scanline] = []
        for y in y1...y2 {
            lines.append(Scanline(y: y, x1: x1, x2: x2))
        }
        return lines.trimmedScanlines(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
    }

    func type() -> ShapeType {
        .rectangle
    }
    
    var description: String {
        "Rectangle x1=\(x1), y1=\(y1), x2=\(x2), y2=\(y2)"
    }

}
