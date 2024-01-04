import Foundation

struct GeometrizingResult {
    let svg: String
    let thumbnail: Bitmap
}

struct SVGAsyncSequence: AsyncSequence {
    typealias Element = GeometrizingResult

    let bitmap: Bitmap
    let shapeTypes: [Shape.Type]
    let strokeWidth: Int
    let iterations: Int
    let shapesPerIteration: Int
    let iterationOptions: SVGAsyncIterator.IterationOptions

    func makeAsyncIterator() -> SVGAsyncIterator {
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
