import Foundation

/// Encapsulates options for where shapes may be drawn within the image.
/// Defines a rectangle expressed as percentages (0-100%) of the target image dimensions
public struct ImageRunnerShapeBoundsOptions {
    /// Whether to use these bounds, or to use the bounds of the target image instead
    /// (these can't be larger than the image in any case).
    var enabled: Bool
    var xMinPercent: Double
    var yMinPercent: Double
    var xMaxPercent: Double
    var yMaxPercent: Double

    public init() {
        enabled = false
        xMinPercent = 0.0
        yMinPercent = 0.0
        xMaxPercent = 100.0
        yMaxPercent = 100.0
    }

    public init(enabled: Bool, xMinPercent: Double, yMinPercent: Double, xMaxPercent: Double, yMaxPercent: Double) {
        self.enabled = enabled
        self.xMinPercent = xMinPercent
        self.yMinPercent = yMinPercent
        self.xMaxPercent = xMaxPercent
        self.yMaxPercent = yMaxPercent
    }
}

/// Encapsulates preferences/options that the image runner uses.
public struct ImageRunnerOptions {

    /// The shape types that the image runner shall use.
    var shapeTypes: Set<ShapeType>

    /// The alpha/opacity of the shapes (0-255).
    var alpha: UInt8

    /// The number of candidate shapes that will be tried per model step.
    var shapeCount: Int

    /// The maximum number of times each candidate shape will be modified to attempt to find a better fit.
    var maxShapeMutations: Int

    /// The seed for the random number generators used by the image runner.
    var seed: Int

    /// The maximum number of separate threads for the implementation to use.
    /// 0 lets the implementation choose a reasonable number.
    var maxThreads: Int

    /// If zero or do not form a rectangle, the entire target image is used i.e. (0, 0, imageWidth, imageHeight).
    var shapeBounds: ImageRunnerShapeBoundsOptions

    public init(shapeTypes: Set<ShapeType>, alpha: UInt8, shapeCount: Int, maxShapeMutations: Int, seed: Int, maxThreads: Int, shapeBounds: ImageRunnerShapeBoundsOptions) {
        self.shapeTypes = shapeTypes
        self.alpha = alpha
        self.shapeCount = shapeCount
        self.maxShapeMutations = maxShapeMutations
        self.seed = seed
        self.maxThreads = maxThreads
        self.shapeBounds = shapeBounds
    }
}

/// Helper for creating a set of primitives from a source image.
public struct ImageRunner {

    /// Creates a new image runner with the given target bitmap.
    /// Uses the average color of the target as the starting image.
    public init(targetBitmap: Bitmap) {
        model = GeometrizeModelHillClimb(targetBitmap: targetBitmap)
    }

    /// Creates an image runner with the given target bitmap, starting from the given initial bitmap.
    /// The target bitmap and initial bitmap must be the same size (width and height).
    /// - Parameters:
    ///   - targetBitmap: The target bitmap to replicate with shapes.
    ///   - initialBitmap: The starting bitmap.
    public init(targetBitmap: Bitmap, initialBitmap: Bitmap) {
        model = GeometrizeModelHillClimb(target: targetBitmap, initial: initialBitmap)
    }

    /// Makes one step of geometrization trying to add a shape to image improving its geometrization.
    /// - Parameters:
    ///   - options: Various configurable settings for doing the step e.g. the shape types to consider.
    ///   - shapeCreator: An optional function for creating and mutating shapes.
    ///   - energyFunction: A function to calculate the energy.
    ///   - addShapePrecondition: A function to determine whether to accept a shape.
    /// - Returns: a ShapeResult representing a shape added to image or nil if a shape improving image
    /// geometrization wasn't found.
    public mutating func step(
        options: ImageRunnerOptions,
        shapeCreator: (() -> any Shape)? = nil,
        energyFunction: @escaping EnergyFunction,
        addShapePrecondition: @escaping ShapeAcceptancePreconditionFunction
    ) -> ShapeResult? {
        let (xMin, yMin, xMax, yMax) = mapShapeBoundsToImage(options: options.shapeBounds, image: model.getTarget())
        let types = options.shapeTypes

        let shapeCreator: () -> any Shape = shapeCreator ?? createDefaultShapeCreator(types: types, canvasBounds: Bounds(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax))

        model.setSeed(options.seed)

        return model.step(
            shapeCreator: shapeCreator,
            alpha: options.alpha,
            shapeCount: options.shapeCount,
            maxShapeMutations: options.maxShapeMutations,
            maxThreads: options.maxThreads,
            energyFunction: energyFunction,
            addShapePrecondition: addShapePrecondition
        )
    }

    public var currentBitmap: Bitmap {
        model.currentBitmap
    }

    // The model for the primitive optimization/fitting algorithm.
    private var model: GeometrizeModelHillClimb
}
