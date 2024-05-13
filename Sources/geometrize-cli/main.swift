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

var shapeData: [ShapeResult] = []

let geometrizingSequence = GeometrizingSequence(
    bitmap: targetBitmap,
    shapeTypes: shapeTypes,
    strokeWidth: strokeWidth,
    iterations: 10,
    shapesPerIteration: shapeCount / 10
)

for iteration in geometrizingSequence {
    shapeData.append(contentsOf: iteration)
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
