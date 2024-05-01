import XCTest
import PNG
@testable import Geometrize

final class ImageRunnerTests: XCTestCase {

    func testImageRunner() throws {
        throw XCTSkip("Randomness should be somehow handled in this test.")

        // seedRandomGenerator(9001)

        let url = Bundle.module.url(forResource: "kris", withExtension: "png")!
        let image: PNG.Image = try .decompress(path: url.path)!
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
        while shapeData.count <= 1000 {
            print("Step \(counter)", terminator: "")
            let shapeResult = runner.step(
                options: options,
                shapeCreator: nil,
                energyFunction: defaultEnergyFunction,
                addShapePrecondition: defaultAddShapePrecondition
            )
            if let shapeResult {
                shapeData.append(shapeResult)
            }
            print(", \(shapeResult == nil ? "no" : "1") shape was added. Total count of shapes \(shapeData.count ).")
            counter += 1
        }

        let svg = SVGExporter().export(data: shapeData, width: width, height: height)

        print(svg)
    }

}
