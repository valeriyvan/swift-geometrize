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

    private let debugPrint: Bool

    public init(
        bitmap: Bitmap,
        downscaleToMaxSize downscaleSize: Int = 500,
        shapeTypes: [Shape.Type],
        strokeWidth: Int,
        iterations: Int,
        shapesPerIteration: Int,
        iterationOptions: IterationOptions = .completeSVGEachIteration,
        debugPrint: Bool = false
    ) {
        self.shapeTypes = shapeTypes
        self.iterations = iterations
        self.shapesPerIteration = shapesPerIteration
        if case .completeSVGFirstIterationThenDeltas(let updateMarker) = iterationOptions {
            precondition(!updateMarker.isEmpty)
        }
        self.iterationOptions = iterationOptions
        self.debugPrint = debugPrint

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

    public mutating func next() async throws -> GeometrizingResult? { // swiftlint:disable:this cyclomatic_complexity
        guard iterationCounter < iterations else { return nil }
        var stepShapeData: [ShapeResult] = []
        while stepShapeData.count < shapesPerIteration {
            if debugPrint {
                print("Step \(stepCounter)", terminator: "")
            }
            let stepResult = runner.step(
                options: runnerOptions,
                shapeCreator: nil,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            if let stepResult {
                if debugPrint {
                    print(", \(stepResult.shape.description) added.", terminator: "")
                }
                stepShapeData.append(stepResult)
            } else {
                if debugPrint {
                    print(", no shapes added.", terminator: "")
                }
            }
            if debugPrint {
                print(" Total count of shapes \(shapeData.count + stepShapeData.count).")
            }
            stepCounter += 1
        }

        shapeData.append(contentsOf: stepShapeData)

        var svg: String
        switch iterationOptions {
        case .completeSVGEachIteration:
            svg = SVGExporter().exportCompleteSVG(data: shapeData, width: width, height: height, originWidth: originWidth, originHeight: originHeight)
        case .completeSVGFirstIterationThenDeltas(let updateMarker) where iterationCounter == 0:
            svg = SVGExporter().exportCompleteSVG(data: shapeData, width: width, height: height, originWidth: originWidth, originHeight: originHeight, updateMarker: updateMarker)
        case .completeSVGFirstIterationThenDeltas where iterationCounter > 0:
            svg = SVGExporter().exportShapesAsSVGFragment(data: shapeData)
        case .completeSVGFirstIterationThenDeltas:
            fatalError()
        }

        iterationCounter += 1

        if debugPrint {
            print("Iteration \(iterationCounter) complete, \(stepShapeData.count) shapes in iteration, \(shapeData.count) shapes in total.")
        }
        return GeometrizingResult(svg: svg, thumbnail: runner.currentBitmap)
    }

}
