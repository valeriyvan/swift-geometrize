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
public func createDefaultShapeCreator(types: Set<ShapeType>, canvasBounds: Bounds) -> () -> any Shape {
    return {
        switch types[types.index(types.startIndex, offsetBy: randomRange(min: 0, max: types.count - 1))] {
        case .rectangle: return Rectangle(canvasBoundsProvider: { canvasBounds })
        case .rotatedRectangle: return RotatedRectangle(canvasBoundsProvider: { canvasBounds })
        case .rotatedEllipse: return RotatedEllipse(canvasBoundsProvider: { canvasBounds })
        case .triangle: return Triangle(canvasBoundsProvider: { canvasBounds })
        case .circle: return Circle(canvasBoundsProvider: { canvasBounds })
        case .ellipse: return Ellipse(canvasBoundsProvider: { canvasBounds })
        case .line: return Line(canvasBoundsProvider: { canvasBounds })
        case .polyline: return Polyline(canvasBoundsProvider: { canvasBounds })
        case .quadraticBezier: return QuadraticBezier(canvasBoundsProvider: { canvasBounds })
        }
    }
}
