import Foundation
import Geometrize
import ArgumentParser
import PNG
import JPEG

struct GeometrizeOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Input file pathname.") var inputPath: String
    @Option(name: .shortAndLong, help: "Output file pathname.") var outputPath: String
    @Option(name: [.customShort("t"), .long], help: "The types of shapes to generate.") var shapeTypes: String = "rectangle"
    @Option(name: [.customShort("c"), .long], help: "The number of shapes to generate for the final output.") var shapeCount: UInt?
    @Flag(name: .shortAndLong, help: "Verbose output.") var verbose: Bool = false
}

//print("Available shaped: \(ShapeType.allCases.map(\.rawValueCapitalized).joined(by: ", ")).")

let options = GeometrizeOptions.parseOrExit()

let inputUrl = URL(fileURLWithPath: options.inputPath)
guard ["png", "jpeg", "jpg"].contains(inputUrl.pathExtension.lowercased()) else {
    print("Only PNG and JPEG input file formats are supported at the moment.")
    exit(1)
}

let targetBitmap: Bitmap
let width, height: Int

switch inputUrl.pathExtension.lowercased() {
case "png":
    guard let image: PNG.Data.Rectangular = try .decompress(path: inputUrl.path) else {
        print("Cannot read or decode input file \(inputUrl.path).")
        exit(1)
    }

    let rgba: [PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self)
    (width, height) = image.size

    let data: [UInt8] = rgba.flatMap({ [$0.r, $0.g, $0.b, $0.a] })
    targetBitmap = Bitmap(width: width, height: height, data: data)
case "jpeg", "jpg":
    guard let spectral: JPEG.Data.Spectral<JPEG.Common> = try .decompress(path: inputUrl.path) else {
        print("Cannot read or decode input file \(inputUrl.path).")
        exit(1)
    }

    guard let image: JPEG.Data.Rectangular<JPEG.Common> = try .decompress(path: inputUrl.path) else {
        print("Cannot read or decode input file \(inputUrl.path).")
        exit(1)
    }

    let rgb: [JPEG.RGB] = image.unpack(as: JPEG.RGB.self)
    (width, height) = image.size

    let data: [UInt8] = rgb.flatMap({ [$0.r, $0.g, $0.b, 255] })
    targetBitmap = Bitmap(width: width, height: height, data: data)
default:
    print("Only PNG and JPEG input file formats are supported at the moment.")
    exit(1)
}

let outputUrl = URL(fileURLWithPath: options.outputPath)
guard outputUrl.pathExtension.caseInsensitiveCompare("svg") == .orderedSame else {
    print("Only SVG output file format is supported at the moment.")
    exit(1)
}

// TODO: use ExpressibleByArgument?
let shapeTypes = options.shapeTypes.components(separatedBy: .whitespacesAndNewlines)
let shapesOrNil = shapeTypes.map(ShapeType.init)
let indexOfNil = shapesOrNil.firstIndex(of: nil)
if let indexOfNil = indexOfNil {
    print("Not recognised shape type \(shapeTypes[indexOfNil]). Allowed shape types:")
    ShapeType.allCases.forEach {
        print($0.rawValueCapitalized)
    }
    print("Case insensitive, underscores are ignored, white spaces are delimiters.")
    exit(1)
}

let shapes = Set(shapesOrNil.compactMap { $0 })
print("Using shapes: \(shapes.map(\.rawValueCapitalized).joined(separator: ", ")).")

let shapeCount: Int = Int(options.shapeCount ?? 100)

let runnerOptions = ImageRunnerOptions(
    shapeTypes: shapes,
    alpha: 128,
    shapeCount: 100,
    maxShapeMutations: 100,
    seed: 9001,
    maxThreads: 5,
    shapeBounds: ImageRunnerShapeBoundsOptions(
        enabled: false,
        xMinPercent: 0, yMinPercent: 0, xMaxPercent: 100, yMaxPercent: 100
    )
)

var runner = ImageRunner(targetBitmap: targetBitmap)

var shapeData: [ShapeResult] = []

// Hack to add a single background rectangle as the initial shape
let rect = Rectangle(x1: 0, y1: 0, x2: Double(targetBitmap.width), y2: Double(targetBitmap.height))
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

let svg = SVGExporter().export(data: shapeData, width: width, height: height)

do {
    try svg.write(to: outputUrl, atomically: true, encoding: .utf8)
} catch {
    print("Cannot write output file. \(error)")
}
