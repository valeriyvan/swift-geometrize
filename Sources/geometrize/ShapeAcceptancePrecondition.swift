import Foundation

/// Type alias for a function that is used to decide whether or not to finally add a shape to the image.
/// - Parameters:
///   - lastScore The image similarity score prior to adding the shape.
///   - newScore What the image similarity score would be after adding the shape.
///   - shape The shape that this function shall decide whether to add.
///   - lines The scanlines for the pixels in the shape.
///   - color The colour of the shape.
///   - before The image prior to adding the shape.
///   - after The image as it would be after adding the shape
///   - target The image that we are trying to replicate.
/// - Returns: True to add the shape to the image, false not to.
public typealias ShapeAcceptancePreconditionFunction = @Sendable (
    _ lastScore: Double,
    _ newScore: Double,
    _ shape: any Shape,
    _ lines: [Scanline],
    _ color: Rgba,
    _ before: Bitmap,
    _ after: Bitmap,
    _ target: Bitmap
) -> Bool

@Sendable public func defaultAddShapePrecondition( // swiftlint:disable:this function_parameter_count
    lastScore: Double,
    newScore: Double,
    shape: any Shape,
    lines: [Scanline],
    color: Rgba,
    _: Bitmap,
    _: Bitmap,
    _: Bitmap
) -> Bool {
    newScore < lastScore // Adds the shape if the score improved (that is: the difference decreased)
}
