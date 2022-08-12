import Foundation

// Specifies the types of shapes that can be used.
// These can be combined to produce images composed of multiple primitive types.
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

class Shape {
    init() {}
    func setup() {}
    func mutate() {}
    func rasterize() -> [Scanline] { [] }
    func type() -> ShapeType { .rectangle }
}
