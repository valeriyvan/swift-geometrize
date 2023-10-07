import Foundation

public typealias ShapeCreator = (inout SplitMix64) -> any Shape

/// Creates a function for creating instances of  Shape. Returned instances should be set up!
/// - Parameters:
///   - types: The types of shapes to create.
///   - xMin: The minimum x coordinate of the shapes created.
///   - yMin: The minimum y coordinate of the shapes created.
///   - xMax: The maximum x coordinate of the shapes created.
///   - yMax: The maximum y coordinate of the shapes created.
/// - Returns: The default shape creator.
public func makeDefaultShapeCreator(types: Set<ShapeType>) -> ShapeCreator {
    return { generator in
        let shape: Shape
        switch types[types.index(types.startIndex, offsetBy: Int._random(in: 0...types.count - 1, using: &generator))] {
        case .rectangle: shape = Rectangle()
        case .rotatedRectangle: shape = RotatedRectangle()
        case .rotatedEllipse: shape = RotatedEllipse()
        case .triangle: shape = Triangle()
        case .circle: shape = Circle()
        case .ellipse: shape = Ellipse()
        case .line: shape = Line()
        case .polyline: shape = Polyline()
        case .quadraticBezier: shape = QuadraticBezier()
        }
        return shape
    }
}
