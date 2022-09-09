import Foundation

public var canvasBounds: (xMin: Int, yMin: Int, xMax: Int, yMax: Int) = (0, 0, .max, .max)

// Specifies the types of shapes that can be used.
// These can be combined to produce images composed of multiple primitive types.
// TODO: put it inside Shape. Or remove completely.
public enum ShapeType: String, CaseIterable {
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

public protocol Shape: AnyObject, CustomStringConvertible {
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

    public func setup() {
        setup(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

    public func mutate() {
        mutate(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

    public func rasterize() -> [Scanline] {
        rasterize(xMin: canvasBounds.xMin, yMin: canvasBounds.yMin, xMax: canvasBounds.xMax, yMax: canvasBounds.yMax)
    }

}


func ==(lhs: any Shape, rhs: any Shape) -> Bool {
    switch (lhs, rhs) {
    case (let lhs as Rectangle, let rhs as Rectangle): return lhs == rhs
    default: return false
    }
}
