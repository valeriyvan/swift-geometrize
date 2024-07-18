import Foundation

public enum SVGAsyncGeometrizer {

    // Returns SVGAsyncSequence which produces intermediate geometrizing results
    // which are SVG strings + thumbnails. The last sequence element is final result.
    public static func geometrize( // swiftlint:disable:this function_parameter_count
        bitmap: Bitmap,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        iterationOptions: SVGAsyncIterator.IterationOptions
    ) async throws -> SVGAsyncSequence {
        SVGAsyncSequence(
            bitmap: bitmap,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            iterationOptions: iterationOptions
        )
    }

}
