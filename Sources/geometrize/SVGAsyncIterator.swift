import Foundation

struct SVGAsyncIterator: AsyncIteratorProtocol {
    private let originalPhotoWidth: Int
    private let originalPhotoHeight: Int
    private let shapeTypes: [Shape.Type]
    private let iterations: Int
    private let shapesPerIteration: Int

    private let width, height: Int

    private var iterationCounter: Int

    private var shapeData: [ShapeResult]

    private let runnerOptions: ImageRunnerOptions
    private var runner: ImageRunner

    // Counts attempts to add shapes. Not all attempts to add shape result in adding a shape.
    private var stepCounter: Int

    init(
        bitmap: Bitmap,
        downscaleImageToMaxSize downscaleSize: Int = 500,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int
    ) {
        self.shapeTypes = shapeTypes
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration

        var targetBitmap = bitmap
        originalPhotoWidth = bitmap.width
        originalPhotoHeight = bitmap.height
        let maxSize = max(originalPhotoWidth, originalPhotoHeight)
        if maxSize > downscaleSize {
            targetBitmap = bitmap.downsample(factor: maxSize / downscaleSize)
        }

        width = targetBitmap.width
        height = targetBitmap.height

        iterationCounter = 0

        stepCounter = 0

        runnerOptions = ImageRunnerOptions(
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            alpha: 128,
            shapeCount: 500, // ?
            maxShapeMutations: 100,
            seed: 9001, // !
            maxThreads: 1,
            shapeBounds: ImageRunnerShapeBoundsOptions(
                enabled: false,
                xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
            )
        )

        runner = ImageRunner(targetBitmap: targetBitmap)

        shapeData = []

        // Hack to add a single background rectangle as the initial shape
        shapeData.append(
            ShapeResult(
                score: 0,
                color: targetBitmap.averageColor(),
                shape: Rectangle(canvasWidth: targetBitmap.width, height: targetBitmap.height)
            )
        )
    }

    mutating func next() async throws -> GeometrizingResult? {
        guard iterationCounter < iterations else { return nil }
        var stepShapeData: [ShapeResult] = []
        while stepShapeData.count < shapesPerIteration {
            print("Step \(stepCounter)", terminator: "")
            let stepResult = runner.step(
                options: runnerOptions,
                shapeCreator: nil,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            if let stepResult {
                print(", \(stepResult.shape.description) added.", terminator: "")
                stepShapeData.append(stepResult)
            } else {
                print(", no shapes added.", terminator: "")
            }
            print(" Total count of shapes \(shapeData.count + stepShapeData.count).")
            stepCounter += 1
        }

        shapeData.append(contentsOf: stepShapeData)
        iterationCounter += 1

        var svg = SVGExporter().export(data: shapeData, width: width, height: height)

        // Fix SVG to keep original image size
        let range = svg.range(of: "width=")!.lowerBound ..< svg.range(of: "viewBox=")!.lowerBound
        svg.replaceSubrange(range.relative(to: svg), with: " width=\"\(originalPhotoWidth)\" height=\"\(originalPhotoHeight)\" ")

        print("Iteration \(iterationCounter) complete, \(stepShapeData.count) shapes in iteration, \(shapeData.count) shapes in total.")
        return GeometrizingResult(svg: svg, thumbnail: runner.currentBitmap)
    }

}
