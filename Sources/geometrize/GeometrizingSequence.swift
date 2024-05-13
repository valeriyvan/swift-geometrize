import Foundation

public struct GeometrizingSequence: Sequence {

    public typealias Element = [ShapeResult]

    let bitmap: Bitmap
    let shapeTypes: [Shape.Type]
    let strokeWidth: Int
    let iterations: Int
    let shapesPerIteration: Int
    let verbose: Bool

    init(
        bitmap: Bitmap,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        verbose: Bool = false
    ) {
        self.bitmap = bitmap
        self.shapeTypes = shapeTypes
        self.strokeWidth = strokeWidth
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration
        self.verbose = verbose
    }

    public func makeIterator() -> GeometrizingIterator {
        GeometrizingIterator(
            bitmap: bitmap,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            verbose: verbose
        )
    }

}
