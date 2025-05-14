import Foundation

public struct GeometrizingIterator: IteratorProtocol {

    private let originWidth: Int
    private let originHeight: Int
    private let shapeTypes: [Shape.Type]
    private let iterations: Int
    private let shapesPerIteration: Int

    private var targetBitmap: Bitmap
    private let width, height: Int // downscaled targetBitmap

    private var iterationCounter: Int

    private var shapeData: [ShapeResult] // TODO: remove

    private let runnerOptions: ImageRunnerOptions
    private var runner: ImageRunner

    // Counts attempts to add shapes. Not all attempts to add shape result in adding a shape.
    private var stepCounter: Int

    private let verbose: Bool

    public enum State {
        case running
        case succeeded
        case succeededMatched
        case failed
    }

    public var state: State

    public init(
        bitmap: Bitmap,
        downscaleToMaxSize downscaleSize: Int = 500,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        verbose: Bool = true
    ) {
        self.shapeTypes = shapeTypes
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration
        self.verbose = verbose

        targetBitmap = bitmap
        originWidth = bitmap.width
        originHeight = bitmap.height
        let maxSize = max(originWidth, originHeight)
        if maxSize > downscaleSize {
            targetBitmap = bitmap.downsample(factor: maxSize / downscaleSize)
        }

        width = targetBitmap.width
        height = targetBitmap.height

        iterationCounter = 0

        stepCounter = 0

        // TODO: parameterize this
        runnerOptions = ImageRunnerOptions(
            shapeTypes: shapeTypes,
            strokeWidth: strokeWidth,
            alpha: 128,
            shapeCount: 500, // TODO: ???
            maxShapeMutations: 100,
            seed: 9001, // TODO: !!!
            maxThreads: 1,
            shapeBounds: ImageRunnerShapeBoundsOptions(
                enabled: false,
                xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
            )
        )

        runner = ImageRunner(targetBitmap: targetBitmap)

        shapeData = []

        state = .running
    }

    public mutating func next() -> [ShapeResult]? { // swiftlint:disable:this cyclomatic_complexity function_body_length
        guard state == .running else { return nil }

        guard iterationCounter < iterations else {
            state = .succeeded
            return nil
        }

        var iterationShapeData: [ShapeResult] = []

        if iterationCounter == 0 {
            // Hack to add a single background rectangle as the initial shape
            iterationShapeData.append(
                ShapeResult(
                    score: 0,
                    color: targetBitmap.averageColor(),
                    shape: Rectangle(canvasWidth: targetBitmap.width, height: targetBitmap.height)
                )
            )
        }

        loop: while iterationShapeData.count <= shapesPerIteration {
            if verbose {
                print("Step \(stepCounter)", terminator: "")
            }
            let stepResult = runner.step(
                options: runnerOptions,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            switch stepResult {
            case .success(let shapeResult):
                iterationShapeData.append(shapeResult)
                if verbose {
                    print(", \(shapeResult.shape.description) added.", terminator: "")
                }
            case .match:
                if verbose {
                    print(", geometrizing matched source image.", terminator: "")
                }
                state = .succeededMatched
                break loop
            case .failure:
                if verbose {
                    print(", no shapes added.", terminator: "")
                }
                    state = .failed
                    break loop
            }
            if verbose {
                print(" Total count of shapes \(shapeData.count + iterationShapeData.count).")
            }
            stepCounter += 1
        }

        shapeData.append(contentsOf: iterationShapeData)

        iterationCounter += 1

        if verbose {
            print("Iteration \(iterationCounter) has completed, \(iterationShapeData.count) shapes per iteration, " +
                  "\(shapeData.count) shapes in total.")
        }

        return iterationShapeData
    }

}
