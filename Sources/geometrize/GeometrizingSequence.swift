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

    /// The scale factor between the original image dimensions and the dimensions used for geometrization
    public var scaleFactor: Double {
        let maxSize = Swift.max(bitmap.width, bitmap.height)
        return maxSize > downscaleToMaxSize ? Double(maxSize) / Double(downscaleToMaxSize) : 1.0
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
        return GeometrizingIterator(
            bitmap: bitmap,
            downscaleToMaxSize: downscaleToMaxSize,
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            iterations: iterations,
            shapesPerIteration: shapesPerIteration,
            verbose: verbose
        )
    }

}
