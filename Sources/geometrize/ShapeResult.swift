import Foundation

 // Container for info about a shape added to the model.
struct ShapeResult {
    let score: Double
    let color: Rgba
    let shape: any Shape
}
