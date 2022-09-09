import Foundation

 // Container for info about a shape added to the model.
public struct ShapeResult {
    let score: Double
    let color: Rgba
    let shape: any Shape
    
    public init(score: Double, color: Rgba, shape: any Shape) {
        self.score = score
        self.color = color
        self.shape = shape
    }
}
