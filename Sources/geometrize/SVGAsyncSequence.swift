import Foundation

public struct GeometrizingResult {
    public let svg: String
    public let thumbnail: Bitmap
}

public struct SVGAsyncSequence: AsyncSequence {
    public typealias Element = GeometrizingResult

    let bitmap: Bitmap
    let shapeTypes: [Shape.Type]
    let strokeWidth: Int
    let iterations: Int
    let shapesPerIteration: Int
    let iterationOptions: SVGAsyncIterator.IterationOptions

    public func makeAsyncIterator() -> SVGAsyncIterator {
        SVGAsyncIterator(
            bitmap: bitmap,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            iterationOptions: iterationOptions
        )
    }
}
