import XCTest
//import SnapshotTesting
@testable import Geometrize

final class SVGAsyncGeometrizerTests: XCTestCase {

    func testGeometrize() async throws {
        guard
            let urlSource = Bundle.module.url(forResource: "sunrise_at_sea", withExtension: "ppm"),
            let urlOutput = Bundle.module.url(forResource: "sunrise_at_sea", withExtension: "svg")
        else {
            fatalError()
        }
        let ppmString = try String(contentsOf: urlSource)
        let bitmap = Bitmap(ppmString: ppmString)

        let svgSequence: SVGAsyncSequence = try await SVGAsyncGeometrizer.geometrize(
            bitmap: bitmap,
            shapeTypes: [RotatedEllipse.self],
            strokeWidth: 1,
            iterations: 5,
            shapesPerIteration: 100,
            iterationOptions: .completeSVGEachIteration
        )

        var results: [String] = []

        for try await result in svgSequence {
            let svgLines = result.svg.components(separatedBy: .newlines)
            let svg = svgLines.dropFirst(2).joined(separator: "\n")
            results.append(svg)
        }

        // Unfortunately this crashes
        // assertSnapshot(of: results.last!, as: .lines)

        let svg = try String(contentsOf: urlOutput, encoding: .utf8)

        XCTAssertEqual(results.last!, svg)
    }

}
