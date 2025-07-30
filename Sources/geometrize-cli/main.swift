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

let shapeCount: Int = Int(options.shapeCount ?? 100)

let strokeWidth: Int = Int(options.lineWidth ?? 1)

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

if options.verbose {
    print("Geometrize Options:")
    print("  Input: \(options.inputPath)")
    print("  Output: \(options.outputPath)")
    print("  Shape Types: \(shapeTypes.map { "\(type(of: $0))".dropLast(5) /* drop .Type */ }.joined(separator: ", "))")
    print("  Shape Count: \(shapeCount)")
    print("  Line Width: \(strokeWidth)")
    print("  Verbose: \(options.verbose)")
}

let inputUrl = URL(fileURLWithPath: options.inputPath)

let targetBitmap: Bitmap =
switch inputUrl.pathExtension.lowercased() {
case "png":
    try Bitmap(pngUrl: inputUrl)
case "jpeg", "jpg":
    try Bitmap(jpegData: try Data(contentsOf: inputUrl))
default:
    fatalError("Only PNG and JPEG input file formats are supported at the moment.")
}
let width = targetBitmap.width
let height = targetBitmap.height

if options.verbose {
    print("Size of input image is width: \(width) x height: \(height)")
}

let outputUrl = URL(fileURLWithPath: options.outputPath)
guard options.outputPath == "-" || ["svg", "png", "jpeg", "jpg"].contains(outputUrl.pathExtension.lowercased()) else {
    fatalError("Only SVG, PNG and JPEG output file formats are supported at the moment.")
 }

var shapeData: [ShapeResult] = []

let geometrizingSequence = GeometrizingSequence(
    bitmap: targetBitmap,
    shapeTypes: shapeTypes,
    strokeWidth: strokeWidth,
    iterations: 10,
    shapesPerIteration: shapeCount / 10,
    verbose: options.verbose
)

for iteration in geometrizingSequence {
    shapeData.append(contentsOf: iteration)
}

// Get the original dimensions and scale factor from the sequence
let originalWidth = targetBitmap.width
let originalHeight = targetBitmap.height
let scaleFactor = geometrizingSequence.scaleFactor

if options.verbose && scaleFactor > 1.0 {
    print("Scale factor from original image: \(scaleFactor)")
    print("Image was downscaled for processing: \(originalWidth)x\(originalHeight) → \(Int(Double(originalWidth) / scaleFactor))x\(Int(Double(originalHeight) / scaleFactor))")
}

do {
    let `extension` = options.outputPath == "-" ? "svg" : outputUrl.pathExtension.lowercased()
    switch `extension` {
    case "png", "jpeg", "jpg":
        let exporter = BitmapExporter()
        // Use the original dimensions for the output
        let processedWidth = Int(Double(originalWidth) / scaleFactor)
        let processedHeight = Int(Double(originalHeight) / scaleFactor)
        let bitmap = exporter.export(
            data: shapeData,
            width: processedWidth,
            height: processedHeight,
            originalWidth: originalWidth,
            originalHeight: originalHeight
        )
        let imageData = try `extension` == "png" ? bitmap.pngData() : bitmap.jpegData()
        try imageData.write(to: outputUrl)
    case "svg":
        let processedWidth = Int(Double(originalWidth) / scaleFactor)
        let processedHeight = Int(Double(originalHeight) / scaleFactor)
        let outputWidth: Int, outputHeight: Int
        if let backgroundRectangle = shapeData.first?.shape as? Rectangle {
            outputWidth = Int(backgroundRectangle.x2 - backgroundRectangle.x1)
            outputHeight = Int(backgroundRectangle.y2 - backgroundRectangle.y1)
        } else {
            outputWidth = processedWidth
            outputHeight = processedHeight
        }
        let svg = SVGExporter()
            .exportCompleteSVG(
                data: shapeData,
                width: outputWidth,
                height: outputHeight,
                originWidth: originalWidth,
                originHeight: originalHeight
            )
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
