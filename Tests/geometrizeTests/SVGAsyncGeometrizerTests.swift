import XCTest
import SnapshotTesting
@testable import Geometrize

final class SVGAsyncGeometrizerTests: XCTestCase {

    func testAsyncGeometrizerCompleteSVGEachIteration() async throws {
        //throw XCTSkip("The test should be debugged.")

        guard let urlSource = Bundle.module.url(forResource: "sunrise_at_sea", withExtension: "ppm") else {
            fatalError()
        }
        let ppmString = try String(contentsOf: urlSource)
        let bitmap = try Bitmap(ppmString: ppmString)

        let svgSequence: SVGAsyncSequence = try await SVGAsyncGeometrizer.geometrize(
            bitmap: bitmap,
            shapeTypes: [RotatedEllipse.self],
            strokeWidth: 1,
            iterations: 5,
            shapesPerIteration: 100,
            iterationOptions: .completeSVGEachIteration
        )

        var results: [String] = []

        for await result in svgSequence {
            let svgLines = result.svg.components(separatedBy: .newlines)
            let svg = svgLines.dropFirst(2).joined(separator: "\n")
            results.append(svg)
        }

        assertSnapshot(of: results.last!, as: .lines)
    }

    func testAsyncGeometrizerCompleteSVGFirstIterationThenDeltas() async throws {
        //throw XCTSkip("The test should be debugged.")

        guard let urlSource = Bundle.module.url(forResource: "sunrise_at_sea", withExtension: "ppm") else {
            fatalError("No resource files")
        }
        print("point0")
        let ppmString = try String(contentsOf: urlSource)
        let bitmap = try Bitmap(ppmString: ppmString)

        let updateMarker = "<!-- insert here next shapes -->\n"
        
        print("point1")
        let svgSequence: SVGAsyncSequence = try await SVGAsyncGeometrizer.geometrize(
            bitmap: bitmap,
            shapeTypes: [RotatedEllipse.self],
            strokeWidth: 1,
            iterations: 500,
            shapesPerIteration: 1,
            iterationOptions: .completeSVGFirstIterationThenDeltas(updateMarker: updateMarker)
        )

        var firstSVG: String? = nil
        var svgAdOns: String = ""

        print("point2")
        var counter = 0
        for await result in svgSequence {
            if firstSVG != nil {
                svgAdOns += result.svg
            } else {
                let svgLines = result.svg.components(separatedBy: .newlines)
                firstSVG = svgLines.dropFirst(2).joined(separator: "\n")
            }
            counter += 1
        }

        let fullSVG = try XCTUnwrap(firstSVG?.replacingOccurrences(of: updateMarker, with: svgAdOns))

        assertSnapshot(of: fullSVG, as: .lines)
    }
}
