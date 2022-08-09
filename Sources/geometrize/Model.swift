import Foundation

// Type alias for a function that is used to decide whether or not to finally add a shape to the image
// @param lastScore The image similarity score prior to adding the shape
// @param newScore What the image similarity score would be after adding the shape
// @param shape The shape that this function shall decide whether to add
// @param lines The scanlines for the pixels in the shape
// @param color The colour of the shape
// @param before The image prior to adding the shape
// @param after The image as it would be after adding the shape
// @param target The image that we are trying to replicate
// @return True to add the shape to the image, false not to
//using ShapeAcceptancePreconditionFunction = std::function<bool(
//    double lastScore,
//    double newScore,
//    const geometrize::Shape& shape,
//    const std::vector<geometrize::Scanline>& lines,
//    const geometrize::rgba& color,
//    const geometrize::Bitmap& before,
//    const geometrize::Bitmap& after,
//    const geometrize::Bitmap& target)>;


// The Model class is the model for the core optimization/fitting algorithm.

struct Model {
    
    // Temporarily here. REMOVE.
    init() {}
    
    // Creates a model that will aim to replicate the target bitmap with shapes.
    // @param target The target bitmap to replicate with shapes.
    init(target: Bitmap) {}

    // Creates a model that will optimize for the given target bitmap, starting from the given initial bitmap.
    // The target bitmap and initial bitmap must be the same size (width and height).
    // @param target The target bitmap to replicate with shapes.
    // @param initial The starting bitmap.
    init(target: Bitmap, initial: Bitmap) {}

    // Resets the model back to the state it was in when it was created.
    // @param backgroundColor The starting background color to use.
    mutating func reset(backgroundColor: Rgba) { }

    var width: Int { 0 }
    var height: Int { 0 }

    // Steps the primitive optimization/fitting algorithm.
    // @param shapeCreator A function that will produce the shapes.
    // @param alpha The alpha of the shape.
    // @param shapeCount The number of random shapes to generate (only 1 is chosen in the end).
    // @param maxShapeMutations The maximum number of times to mutate each random shape.
    // @param maxThreads The maximum number of threads to use during this step.
    // @param energyFunction An optional function to calculate the energy (if unspecified a default implementation is used).
    // @param addShapePrecondition An optional function to determine whether to accept a shape (if unspecified a default implementation is used).
    // @return A vector containing data about the shapes added to the model in this step. This may be empty if no shape that improved the image could be found.
    
    //std::vector<geometrize::ShapeResult> step(
    //        const std::function<std::shared_ptr<geometrize::Shape>(void)>& shapeCreator,
    //        std::uint8_t alpha,
    //        std::uint32_t shapeCount,
    //        std::uint32_t maxShapeMutations,
    //        std::uint32_t maxThreads,
    //        const geometrize::core::EnergyFunction& energyFunction = nullptr,
    //        const geometrize::ShapeAcceptancePreconditionFunction& addShapePrecondition = nullptr);

    func step(
        shapeCreator: () -> Shape,
        alpha: UInt8,
        shapeCount: Int,
        maxShapeMutations: Int,
        maxThreads: Int,
        energyFunction: (() -> Double)? = nil,
        addShapePrecondition: ((Shape) -> Bool)? = nil
    ) -> [ShapeResult] {
        []
    }

    // Draws a shape on the model. Typically used when to manually add a shape to the image
    // (e.g. when setting an initial background).
    // NOTE this unconditionally draws the shape, even if it increases the difference between
    // the source and target image.
    // @param shape The shape to draw.
    // @param color The color (including alpha) of the shape.
    // @return Data about the shape drawn on the model.

    func drawShape(shape: Shape, color: Rgba) -> ShapeResult { ShapeResult() }

     // Gets the current bitmap.
     // @return The current bitmap.
    func getCurrent() -> Bitmap { Bitmap() }

     // Gets the target bitmap.
     // @return The target bitmap.
    func getTarget() -> Bitmap { Bitmap() }

    // Sets the seed that the random number generators of this model use.
    // Note that the model also uses an internal seed offset which is incremented when the model is stepped.
    // @param seed The random number generator seed.
    mutating func setSeed(_ seed: Int) {}

}
