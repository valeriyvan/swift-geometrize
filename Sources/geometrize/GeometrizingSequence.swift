import Foundation

public struct GeometrizingSequence: Sequence {

    public typealias Element = [ShapeResult]

    let bitmap: Bitmap
    let shapeTypes: [Shape.Type]
    let strokeWidth: Int
    let iterations: Int
    let shapesPerIteration: Int
    let verbose: Bool
    private let downscaleToMaxSize: Int

    /// Helper class to store the iterator and provide scale factor
    private final class IteratorStorage {
        var iterator: GeometrizingIterator?
    }

    /// Storage for the iterator reference
    private let storage = IteratorStorage()

    /// The scale factor between the original image dimensions and the dimensions used for geometrization
    public var scaleFactor: Double {
        // Create an iterator immediately if needed to get the scale factor
        if storage.iterator == nil {
            let _ = makeIterator()
        }
        return storage.iterator?.scaleFactor ?? 1.0
    }

    /// The original width of the image before downscaling
    public var originalWidth: Int {
        bitmap.width
    }

    /// The original height of the image before downscaling
    public var originalHeight: Int {
        bitmap.height
    }

    public init(
        bitmap: Bitmap,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        downscaleToMaxSize: Int = 500,
        verbose: Bool = false
    ) {
        self.bitmap = bitmap
        self.shapeTypes = shapeTypes
        self.strokeWidth = strokeWidth
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration
        self.downscaleToMaxSize = downscaleToMaxSize
        self.verbose = verbose
    }

    public func makeIterator() -> GeometrizingIterator {
        let newIterator = GeometrizingIterator(
            bitmap: bitmap,
            downscaleToMaxSize: downscaleToMaxSize,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            verbose: verbose
        )
        storage.iterator = newIterator
        return newIterator
    }

}
