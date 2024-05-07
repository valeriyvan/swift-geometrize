import Foundation
import Geometrize
import ArgumentParser
import PNG
import JPEG
import BitmapImportExport

struct GeometrizeOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Input file pathname."
    ) var inputPath: String
    @Option(
        name: .shortAndLong,
        help: "Output file pathname."
    ) var outputPath: String
    @Option(
        name: [.customShort("t"), .long],
        help: "White space separated list of shapes to use geometrizing image."
    ) var shapeTypes: String = "rectangle"
    @Option(
        name: [.customShort("c"), .long],
        help: "The number of shapes to generate for the final output."
    ) var shapeCount: UInt?
    @Option(
        name: [.customShort("w"), .long],
        help: "Width of lines, polylines, bezier curves."
    ) var lineWidth: UInt?
    @Flag(
        name: .shortAndLong,
        help: "Verbose output."
    ) var verbose: Bool = false
}

let options = GeometrizeOptions.parseOrExit()

let inputUrl = URL(fileURLWithPath: options.inputPath)

let targetBitmap: Bitmap =
switch inputUrl.pathExtension.lowercased() {
case "png":
    try Bitmap(pngUrl: inputUrl)
case "jpeg", "jpg":
    try Bitmap(jpegUrl: inputUrl)
default:
        fatalError("Only PNG and JPEG input file formats are supported at the moment.")
}
let width = targetBitmap.width
let height = targetBitmap.height

let outputUrl = URL(fileURLWithPath: options.outputPath)
guard options.outputPath == "-" || ["svg", "png", "jpeg", "jpg"].contains(outputUrl.pathExtension.lowercased()) else {
    fatalError("Only SVG, PNG and JPEG output file formats are supported at the moment.")
 }

// TODO: use ExpressibleByArgument?
let shapesStrings = options.shapeTypes.components(separatedBy: .whitespacesAndNewlines)
let shapes = shapesStrings.shapeTypes()

// Shape.Type is not hashable as all Metatypes. Why, by the way?
// That why we check for nil in this strange way.
var indexOfNil: Int?
for (i, shape) in shapes.enumerated() where shape == nil {
    indexOfNil = i
    break
}

if let indexOfNil {
    print("Not recognised shape type \(shapesStrings[indexOfNil]). Allowed shape types:")
    allShapeTypes.forEach {
        print("\($0)")
    }
    print("Case insensitive, underscores are ignored, white spaces are delimiters.")
    exit(1)
}

let shapeTypes: [Shape.Type] = shapes.compactMap { $0 }

print("Using shapes: \(shapeTypes.map { "\(type(of: $0))".dropLast(5) /* drop .Type */ }.joined(separator: ", ")).")

let shapeCount: Int = Int(options.shapeCount ?? 100)

let strokeWidth: Int = Int(options.lineWidth ?? 1)

let runnerOptions = ImageRunnerOptions(
    shapeTypes: shapeTypes,
    strokeWidth: strokeWidth,
    alpha: 128,
    shapeCount: 100,
    maxShapeMutations: 100,
    seed: 9001, // TODO: !!!
    maxThreads: 5,
    shapeBounds: ImageRunnerShapeBoundsOptions(
        enabled: false,
        xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
    )
)

var runner = ImageRunner(targetBitmap: targetBitmap)

var shapeData: [ShapeResult] = []

// Hack to add a single background rectangle as the initial shape
let rect = Rectangle(strokeWidth: 1, x1: 0, y1: 0, x2: Double(targetBitmap.width), y2: Double(targetBitmap.height))
shapeData.append(ShapeResult(score: 0, color: targetBitmap.averageColor(), shape: rect))

var counter = 0
// Here in shapeCount set count of shapes final image should have.
// Remember background is the first shape.
while shapeData.count <= shapeCount {
    if options.verbose {
        print("Step \(counter)", terminator: "")
    }
    let shapeResult = runner.step(
        options: runnerOptions,
        shapeCreator: nil,
        energyFunction: defaultEnergyFunction,
        addShapePrecondition: defaultAddShapePrecondition
    )
    if let shapeResult {
        shapeData.append(shapeResult)
        if options.verbose {
            print(", \(shapeResult.shape.description) added.", terminator: "")
        }
    } else {
        if options.verbose {
            print(", no shapes added.", terminator: "")
        }
    }
    if options.verbose {
        print(" Total count of shapes \(shapeData.count ).")
    }
    counter += 1
}

do {
    let `extension` = options.outputPath == "-" ? "svg" : outputUrl.pathExtension.lowercased()
    switch `extension` {
    case "png":
        let exporter = BitmapExporter()
        let bitmap = exporter.export(data: shapeData, width: width, height: height)
        let pngData = try bitmap.pngData()
        try pngData.write(to: outputUrl)
    case "jpeg", "jpg":
        let exporter = BitmapExporter()
        let bitmap = exporter.export(data: shapeData, width: width, height: height)
        let jpegData = try bitmap.jpegData()
        try jpegData.write(to: outputUrl)
    case "svg":
        let svg = SVGExporter().export(data: shapeData, width: width, height: height)
        if options.outputPath == "-" {
            print(svg)
        } else {
            try svg.write(to: outputUrl, atomically: true, encoding: .utf8)
        }
    default:
        fatalError("File format \(outputUrl.pathExtension) for output is not supported at the moment.")
    }
} catch {
    print("Error writing output file: \(error)")
}
