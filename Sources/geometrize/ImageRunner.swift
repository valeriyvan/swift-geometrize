import Foundation

struct ImageRunnerOptions {}

// Helper for creating a set of primitives from a source image.
struct ImageRunner {
    
    // Creates a new image runner with the given target bitmap.
    // Uses the average color of the target as the starting image.
    init(targetBitmap: Bitmap) {}

    // Creates an image runner with the given target bitmap, starting from the given initial bitmap.
    // The target bitmap and initial bitmap must be the same size (width and height).
    // @param targetBitmap The target bitmap to replicate with shapes.
    // @param initialBitmap The starting bitmap.
    init(targetBitmap: Bitmap, initialBitmap: Bitmap) {}


    // Updates the internal model once.
    // @param options Various configurable settings for doing the step e.g. the shape types to consider.
    // @param shapeCreator An optional function for creating and mutating shapes
    // @param energyFunction An optional function to calculate the energy (if unspecified a default implementation is used).
    // @param addShapePrecondition An optional function to determine whether to accept a shape (if unspecified a default implementation is used).
    // @return A vector containing data about the shapes just added to the internal model.
    
    //std::vector<geometrize::ShapeResult> step(const geometrize::ImageRunnerOptions& options,
    //                                          std::function<std::shared_ptr<geometrize::Shape>()> shapeCreator,
    //                                          geometrize::core::EnergyFunction energyFunction,
    //                                          geometrize::ShapeAcceptancePreconditionFunction addShapePrecondition)

    
    func step(
        options: ImageRunnerOptions,
        shapeCreator: (() -> Shape)? = nil,
        energyFunction: ((Bitmap) -> Int)? = nil,
        addShapePrecondition: ((Shape) -> Bool)? = nil
    )
    {
        //const auto [xMin, yMin, xMax, yMax] = geometrize::commonutil::mapShapeBoundsToImage(options.shapeBounds, m_model.getTarget());
        //const geometrize::ShapeTypes types = options.shapeTypes;
        //
        //if(!shapeCreator) {
        //    shapeCreator = geometrize::createDefaultShapeCreator(types, xMin, yMin, xMax, yMax);
        //}
        //
        //m_model.setSeed(options.seed);
        //return m_model.step(shapeCreator, options.alpha, options.shapeCount, options.maxShapeMutations, options.maxThreads, energyFunction, addShapePrecondition);
    }
    
    // Gets the current bitmap with the primitives drawn on it.
    // @return The current bitmap.
    func getCurrent() -> Bitmap { Bitmap() }

    // Gets the target bitmap.
    // @return The target bitmap.
    func getTarget() -> Bitmap { Bitmap() }

    // getModel Gets the underlying model.
    // @return The model.
    func getModel() -> Model { Model() }
    
}

