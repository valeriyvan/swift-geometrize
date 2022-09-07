import Foundation

// Creates an instance of the default shape creator object.
// The setup, mutate and rasterize methods are bound with default methods.
// @param types The types of shapes to create.
// @param xMin The minimum x coordinate of the shapes created.
// @param yMin The minimum y coordinate of the shapes created.
// @param xMax The maximum x coordinate of the shapes created.
// @param yMax The maximum y coordinate of the shapes created.
// @return The default shape creator.
func createDefaultShapeCreator(type: ShapeType, xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> () -> any Shape {
    {
        let shape = randomShape(type: type)
        canvasBounds = (xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)
        switch type {
        case .rectangle:
            return shape as! Rectangle
        case .rotatedRectangle:
            return shape as! RotatedRectangle
        case .rotatedEllipse:
            return shape as! RotatedEllipse
        default:
            fatalError("Unimplemented")
        }
    }
}

// Creates a random shape from the types supplied.
// @param t The types of shape to possibly create.
// @return The new shape.
// Original C++ implementation allows mask parameter and so different shapes
// could be used.
func randomShape(type: ShapeType) -> any Shape {
    switch type {
    case .rectangle: return Rectangle()
    case .rotatedRectangle: return RotatedRectangle()
    case .rotatedEllipse: return RotatedEllipse()
    default: fatalError()
    }
}
