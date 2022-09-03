import Foundation

// https://www.advancedswift.com/swift-random-numbers/
fileprivate struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(_ seed: Int) {
        srand48(seed)
    }

    func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}

fileprivate var generator = RandomNumberGeneratorWithSeed(0)

// seedRandomGenerator Seeds the (thread-local) random number generators.
// @param seed The random seed.
// TODO: make it thread-local
func seedRandomGenerator(_ seed: Int) {
    generator = RandomNumberGeneratorWithSeed(seed)
}

var randomRangeImplementationReference = randomRangeImplementation

private func randomRangeImplementation(_ min: Int, _ max: Int) -> Int {
    let random = Int.random(in: min...max, using: &generator)
    return random
}

// Returns a random integer in the range, inclusive. Uses thread-local random number generators under the hood.
// To ensure deterministic shape generation that can be repeated for different seeds, this should be used for shape mutation, but nothing else.
// @param min The lower bound.
// @param max The upper bound.
// @return The random integer in the range.
func randomRange(min: Int, max: Int) -> Int {
    randomRangeImplementationReference(min, max)
}

// Maps the given shape bound percentages to the given image, returning a bounding rectangle, or the whole image if the bounds were invalid
// @param The options to map to the image
// @param The image to map the options around
// @return The mapped shape bounds (xMin, yMin, xMax, yMax)
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
