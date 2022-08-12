import Foundation

// Encapsulates options for where shapes may be drawn within the image.
// Defines a rectangle expressed as percentages (0-100%) of the target image dimensions
struct ImageRunnerShapeBoundsOptions {
    // Whether to use these bounds, or to use the bounds of the target image instead
    // (these can't be larger than the image in any case).
    var enabled: Bool = false
    var xMinPercent: Double = 0.0
    var yMinPercent: Double = 0.0
    var xMaxPercent: Double = 100.0
    var yMaxPercent: Double = 100.0
}

// Encapsulates preferences/options that the image runner uses.
struct ImageRunnerOptions {
    
    // The shape type that the image runner shall use.
    var shapeType: ShapeType = .ellipse
    
    // The alpha/opacity of the shapes (0-255).
    var alpha: UInt8 = 128
    
    // The number of candidate shapes that will be tried per model step.
    var shapeCount: Int = 50
    
    // The maximum number of times each candidate shape will be modified to attempt to find a better fit.
    var maxShapeMutations: Int = 100
   
    // The seed for the random number generators used by the image runner.
    var seed: Int = 9001
    
    // The maximum number of separate threads for the implementation to use.
    // 0 lets the implementation choose a reasonable number.
    var maxThreads: Int = 0
    
    // If zero or do not form a rectangle, the entire target image is used i.e. (0, 0, imageWidth, imageHeight).
    var shapeBounds: ImageRunnerShapeBoundsOptions
}

// Helper for creating a set of primitives from a source image.
struct ImageRunner {
    
    // Creates a new image runner with the given target bitmap.
    // Uses the average color of the target as the starting image.
    init(targetBitmap: Bitmap) {
        m_model = Model(target: targetBitmap)
    }

    // Creates an image runner with the given target bitmap, starting from the given initial bitmap.
    // The target bitmap and initial bitmap must be the same size (width and height).
    // @param targetBitmap The target bitmap to replicate with shapes.
    // @param initialBitmap The starting bitmap.
    init(targetBitmap: Bitmap, initialBitmap: Bitmap) {
        m_model = Model(target: targetBitmap, initial: initialBitmap)
    }

    // Updates the internal model once.
    // @param options Various configurable settings for doing the step e.g. the shape types to consider.
    // @param shapeCreator An optional function for creating and mutating shapes
    // @param energyFunction An optional function to calculate the energy (if unspecified a default implementation is used).
    // @param addShapePrecondition An optional function to determine whether to accept a shape (if unspecified a default implementation is used).
    // @return A vector containing data about the shapes just added to the internal model.
    mutating func step(
        options: ImageRunnerOptions,
        shapeCreator: (() -> Shape)? = nil,
        energyFunction: EnergyFunction? = nil,
        addShapePrecondition: ShapeAcceptancePreconditionFunction? = nil
    ) -> [ShapeResult]
    {
        let (xMin, yMin, xMax, yMax) = mapShapeBoundsToImage(options: options.shapeBounds, image: m_model.getTarget())
        let type = options.shapeType
        
        let shapeCreator: () -> Shape = shapeCreator ?? createDefaultShapeCreator(type: type, xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)

        m_model.setSeed(options.seed)

        let result: [ShapeResult] = m_model.step(
            shapeCreator: shapeCreator,
            alpha: options.alpha,
            shapeCount: options.shapeCount,
            maxShapeMutations: options.maxShapeMutations,
            maxThreads: options.maxThreads,
            energyFunction: energyFunction!, // TODO: !!!
            addShapePrecondition: addShapePrecondition! // TODO: !!!
        )

        return result
    }
    
    // Gets the current bitmap with the primitives drawn on it.
    // @return The current bitmap.
    func getCurrent() -> Bitmap { m_model.getCurrent() }

    // Gets the target bitmap.
    // @return The target bitmap.
    func getTarget() -> Bitmap { m_model.getTarget() }

    // getModel Gets the underlying model.
    // @return The model.
    func getModel() -> Model { m_model }

    // The model for the primitive optimization/fitting algorithm.
    private var m_model: Model
}

