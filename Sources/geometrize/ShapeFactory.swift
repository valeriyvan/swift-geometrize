import Foundation

// Creates an instance of the default shape creator object.
// The setup, mutate and rasterize methods are bound with default methods.
// @param types The types of shapes to create.
// @param xMin The minimum x coordinate of the shapes created.
// @param yMin The minimum y coordinate of the shapes created.
// @param xMax The maximum x coordinate of the shapes created.
// @param yMax The maximum y coordinate of the shapes created.
// @return The default shape creator.
func createDefaultShapeCreator(type: ShapeType, xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> () -> Shape {
    { Shape() }
}
