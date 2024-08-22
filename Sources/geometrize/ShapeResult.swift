import Foundation

 /// Container for info about a shape added to the model.
public struct ShapeResult {
    public let score: Double
    public let color: Rgba
    public let shape: Shape

    public init(score: Double, color: Rgba, shape: Shape) {
        self.score = score
        self.color = color
        self.shape = shape
    }
}
