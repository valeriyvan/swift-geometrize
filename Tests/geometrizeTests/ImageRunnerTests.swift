import XCTest
import PNG
@testable import Geometrize

final class ImageRunnerTests: XCTestCase {

    func testImageRunnerRedImage() throws { // swiftlint:disable:this function_body_length
        let width = 100, height = 100
        let targetBitmap = Bitmap(width: width, height: height, color: .red)

        let options = ImageRunnerOptions(
            shapeTypes: [RotatedEllipse.self],
            strokeWidth: 1,
            alpha: 128,
            shapeCount: 500,
            maxShapeMutations: 100,
            seed: 9001,
            maxThreads: 1,
            shapeBounds: ImageRunnerShapeBoundsOptions(
                enabled: false,
                xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
            )
        )

        var runner = ImageRunner(targetBitmap: targetBitmap)

        var shapeData: [ShapeResult] = []

        // Hack to add a single background rectangle as the initial shape
        let rect = Rectangle(
            strokeWidth: 1,
            x1: 0, y1: 0,
            x2: Double(targetBitmap.width), y2: Double(targetBitmap.height)
        )
        shapeData.append(ShapeResult(score: 0, color: targetBitmap.averageColor(), shape: rect))

        var counter = 0
        // Here set count of shapes final image should have. Remember background is the first shape.
        loop: while shapeData.count <= 1000 {
            print("Step \(counter)", terminator: "")
            let stepResult = runner.step(
                options: options,
                shapeCreator: nil,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            switch stepResult {
            case .success(let shapeResult):
                shapeData.append(shapeResult)
                print(", \(shapeResult.shape.description) added.", terminator: "")
            case .match:
                //print(", geometrizing matched source image.", terminator: "")
                break loop
            case .failure:
                print(", failure, no shapes added.", terminator: "")
                // TODO: should it break as well?
            }
            print(" Total count of shapes \(shapeData.count ).")
            counter += 1
        }

        XCTAssertEqual(
            SVGExporter()
                .exportCompleteSVG(
                    data: shapeData,
                    width: width, height: height,
                    originWidth: width, originHeight: height
                ),
            """
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
            <svg xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" xmlns="http://www.w3.org/2000/svg"
            width="100" height="100" viewBox="0 0 100 100">
            <rect x="0.0" y="0.0" width="100.0" height="100.0" fill="rgb(255,0,0)" fill-opacity="1.0"/>
            </svg>
            """
        )
    }

    func testImageRunner() throws { // swiftlint:disable:this function_body_length
        throw XCTSkip("Randomness should be somehow handled in this test.")

        // seedRandomGenerator(9001)

        guard let url = Bundle.module.url(forResource: "kris", withExtension: "png") else {
            fatalError("Resource \"kris.png\" not found in bundle")
        }
        guard let image: PNG.Image = try .decompress(path: url.path) else {
            fatalError("Cannot decompress png")
        }
        let rgba: [PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self)
        let (width, height) = image.size

        let data: [UInt8] = rgba.flatMap({ [$0.r, $0.g, $0.b, $0.a] })
        XCTAssertEqual(data.count, width * height * 4)
        let targetBitmap = Bitmap(width: width, height: height, data: data)

        let options = ImageRunnerOptions(
            shapeTypes: [RotatedEllipse.self],
            strokeWidth: 1,
            alpha: 128,
            shapeCount: 500,
            maxShapeMutations: 100,
            seed: 9001,
            maxThreads: 1,
            shapeBounds: ImageRunnerShapeBoundsOptions(
                enabled: false,
                xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
            )
        )

        var runner = ImageRunner(targetBitmap: targetBitmap)

        var shapeData: [ShapeResult] = []

        // Hack to add a single background rectangle as the initial shape
        let rect = Rectangle(
            strokeWidth: 1,
            x1: 0, y1: 0,
            x2: Double(targetBitmap.width), y2: Double(targetBitmap.height)
        )
        shapeData.append(ShapeResult(score: 0, color: targetBitmap.averageColor(), shape: rect))

        var counter = 0
        // Here set count of shapes final image should have. Remember background is the first shape.
        loop: while shapeData.count <= 1000 {
            print("Step \(counter)", terminator: "")
            let stepResult = runner.step(
                options: options,
                shapeCreator: nil,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            switch stepResult {
            case .success(let shapeResult):
                shapeData.append(shapeResult)
                print(", \(shapeResult.shape.description) added.", terminator: "")
            case .match:
                print(", geometrizing matched source image.", terminator: "")
                break loop
            case .failure:
                print(", failure, no shapes added.", terminator: "")
                // TODO: should it break as well?
            }
            print(" Total count of shapes \(shapeData.count ).")
            counter += 1
    }

        let svg = SVGExporter()
            .exportCompleteSVG(
                data: shapeData,
                width: width, height: height,
                originWidth: width, originHeight: height
            )

        print(svg)
    }

}
