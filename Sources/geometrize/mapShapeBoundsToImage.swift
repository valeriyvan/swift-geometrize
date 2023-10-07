import Foundation

/// Maps the given shape bound percentages to the given image, returning a bounding rectangle, or the whole image if the bounds were invalid.
/// - Parameters:
///   - options: The options to map to the image.
///   - image: The image to map the options around.
/// - Returns: The mapped shape bounds (xMin, yMin, xMax, yMax)
func mapShapeBoundsToImage(options: ImageRunnerShapeBoundsOptions, image: Bitmap) -> (xMin: Int, yMin: Int, xMax: Int, yMax: Int) {

    guard options.enabled else {
        return (0, 0, image.width - 1, image.height - 1)
    }

    let xMinPx: Double = options.xMinPercent / 100.0 * Double(image.width - 1)
    let yMinPx: Double = options.yMinPercent / 100.0 * Double(image.height - 1)
    let xMaxPx: Double = options.xMaxPercent / 100.0 * Double(image.width - 1)
    let yMaxPx: Double = options.yMaxPercent / 100.0 * Double(image.height - 1)

    var xMin: Int = Int(min(min(xMinPx, xMaxPx), Double(image.width - 1)).rounded())
    var yMin: Int = Int(min(min(yMinPx, yMaxPx), Double(image.height - 1)).rounded())
    var xMax: Int = Int(min(max(xMinPx, xMaxPx), Double(image.width - 1)).rounded())
    var yMax: Int = Int(min(max(yMinPx, yMaxPx), Double(image.height - 1)).rounded())

    // If we have a bad width or height, which is bound to cause problems - use the whole image
    if xMax - xMin <= 1 {
        xMin = 0
        xMax = image.width - 1
    }
    if yMax - yMin <= 1 {
        yMin = 0
        yMax = image.height - 1
    }

    return (xMin, yMin, xMax, yMax)
}
