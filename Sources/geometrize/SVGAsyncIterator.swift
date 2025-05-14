import Foundation

public struct SVGAsyncIterator: AsyncIteratorProtocol {

    private let originWidth: Int
    private let originHeight: Int
    private let shapeTypes: [Shape.Type]
    private let iterations: Int
    private let shapesPerIteration: Int
    private let iterationOptions: IterationOptions

    private let width, height: Int

    private var iterationCounter: Int

    private var shapeData: [ShapeResult]

    private let runnerOptions: ImageRunnerOptions
    private var runner: ImageRunner

    public enum IterationOptions {
        case completeSVGEachIteration
        case completeSVGFirstIterationThenDeltas(updateMarker: String)
    }

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
        iterationOptions: IterationOptions = .completeSVGEachIteration,
        verbose: Bool = false
    ) {
        self.shapeTypes = shapeTypes
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration
        if case .completeSVGFirstIterationThenDeltas(let updateMarker) = iterationOptions {
            precondition(!updateMarker.isEmpty)
        }
        self.iterationOptions = iterationOptions
        self.verbose = verbose

        var targetBitmap = bitmap
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
            maxThreads: ProcessInfo.processInfo.processorCount - 1,
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

        state = .running
    }

    public mutating func next() async -> GeometrizingResult? { // swiftlint:disable:this cyclomatic_complexity function_body_length line_length
        guard state == .running else { return nil }

        guard iterationCounter < iterations else {
            state = .succeeded
            return nil
        }

        var iterationShapeData: [ShapeResult] = []

        loop: while iterationShapeData.count <= shapesPerIteration {
            if verbose {
                print("Step \(stepCounter)", terminator: "")
            }

            let stepResult = await runner.stepAsync(
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

        var svg: String
        switch iterationOptions {
        case .completeSVGEachIteration:
            svg = SVGExporter()
                .exportCompleteSVG(
                    data: shapeData,
                    width: width,
                    height: height,
                    originWidth: originWidth,
                    originHeight: originHeight
                )
        case .completeSVGFirstIterationThenDeltas(let updateMarker) where iterationCounter == 0:
            svg = SVGExporter()
                .exportCompleteSVG(
                    data: shapeData,
                    width: width,
                    height: height,
                    originWidth: originWidth,
                    originHeight: originHeight,
                    updateMarker: updateMarker
                )
        case .completeSVGFirstIterationThenDeltas where iterationCounter > 0:
            svg = SVGExporter().exportShapesAsSVGFragment(data: iterationShapeData)
        case .completeSVGFirstIterationThenDeltas:
            fatalError()
        }

        iterationCounter += 1

        return GeometrizingResult(svg: svg, thumbnail: runner.currentBitmap)
    }

}
