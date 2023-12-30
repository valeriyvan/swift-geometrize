import Foundation

enum SVGAsyncGeometrizer {

    // Returns SVGAsyncSequence which produces intermediate geometrizing results
    // which are SVG strings + thumbnails. The last sequence element is final result.
    static func geometrize(
        bitmap: Bitmap,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int
    ) async throws -> SVGAsyncSequence {
        SVGAsyncSequence(
            bitmap: bitmap,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration
        )
    }

}
