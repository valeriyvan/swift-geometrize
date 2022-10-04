import Foundation

/// Creates an instance of the default shape creator object.
/// The setup, mutate and rasterize methods are bound with default methods.
/// - Parameters:
///   - types: The types of shapes to create.
///   - xMin: The minimum x coordinate of the shapes created.
///   - yMin: The minimum y coordinate of the shapes created.
///   - xMax: The maximum x coordinate of the shapes created.
///   - yMax: The maximum y coordinate of the shapes created.
/// - Returns: The default shape creator.
public func createDefaultShapeCreator(types: Set<ShapeType>, xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> () -> any Shape {
    canvasBounds = (xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)
    return {
        switch types[types.index(types.startIndex, offsetBy: randomRange(min: 0, max: types.count - 1))] {
        case .rectangle: return Rectangle()
        case .rotatedRectangle: return RotatedRectangle()
        case .rotatedEllipse: return RotatedEllipse()
        case .triangle: return Triangle()
        case .circle: return Circle()
        case .ellipse: return Ellipse()
        case .line: return Line()
        case .polyline: return Polyline()
        case .quadraticBezier: return QuadraticBezier()
        }
    }
}
