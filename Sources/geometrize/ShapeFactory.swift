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
        let shape = randomShapeOf(type)
        canvasBounds = (xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)
        switch type {
        case .rectangle:
            return shape as! Rectangle
        case .rotatedRectangle:
            return shape as! RotatedRectangle
        default:
            fatalError("Unimplemented")
        }
    }
}

// @brief Creates a new shape of the specified type.
// @param t The type of shape to create.
// @return The new shape.
func create(_ type: ShapeType) -> some Shape {
    return Rectangle() // TODO: !!!
}

// @brief Creates a random shape.
// @return The new shape.
func randomShape() -> some Shape {
    return Rectangle() // TODO: by now we have only rectangles
}

// Creates a random shape from the types supplied.
// @param t The types of shape to possibly create.
// @return The new shape.
// Original C++ implementation allows mask parameter and so different shapes
// could be used.
func randomShapeOf(_ type: ShapeType) -> some Shape {
    return Rectangle() // TODO: !!!
}
