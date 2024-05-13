import Foundation

public enum Geometrizer {

    // Returns GeometrizingSequence which produces intermediate geometrizing results.
    public static func geometrize(
        bitmap: Bitmap,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        verbose: Bool = false
    ) -> GeometrizingSequence {
        GeometrizingSequence(
            bitmap: bitmap,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            verbose: verbose
        )
    }

}
