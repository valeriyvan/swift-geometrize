import Foundation
import Geometrize
import PNG
import Algorithms

public extension Bitmap {

    func pngData() throws -> Data {
        let rgba: [PNG.RGBA<UInt8>] = backing.chunks(ofCount: 4).map {
            PNG.RGBA(
                $0[$0.startIndex + 0],
                $0[$0.startIndex + 1],
                $0[$0.startIndex + 2],
                $0[$0.startIndex + 3]
            )
        }
        let image = PNG.Image(
            packing: rgba,
            size: (x: width, y: height),
            layout: PNG.Layout(format: .rgba8(palette: [], fill: nil))
        )
        var destinationStream = DestinationStream()
        try image.compress(stream: &destinationStream)
        return Data(destinationStream.data)
    }

    init(pngData data: Data) throws {
        var stream = SourceStream(data)
        let image: PNG.Image = try decodeOnline(stream: &stream, overdraw: false) { _ in }
        let rgba: [PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self)
        let bitmapData: [UInt8] = rgba.flatMap({ [$0.r, $0.g, $0.b, $0.a] })
        self.init(width: image.size.0, height: image.size.1, data: bitmapData)
    }

    init(pngUrl url: URL) throws {
        guard let image: PNG.Image = try .decompress(path: url.path) else {
            // decompress returns nil when file cannot be open
            throw NSError(domain: URLError.errorDomain, code: URLError.cannotOpenFile.rawValue)
        }
        let rgba: [PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self)
        let data: [UInt8] = rgba.flatMap({ [$0.r, $0.g, $0.b, $0.a] })
        self = Bitmap(width: image.size.x, height: image.size.y, data: data, blending: .white)
    }

}

func waitSignature(stream: inout SourceStream) throws {
    let position: Int = stream.position
    while true {
        do {
            return try stream.signature()
        } catch PNG.LexingError.truncatedSignature {
            stream.reset(position: position)
            continue
        }
    }
}

func waitChunk(stream: inout SourceStream) throws -> (type: PNG.Chunk, data: [UInt8]) {
    let position: Int = stream.position
    while true {
        do {
            return try stream.chunk()
        } catch PNG.LexingError.truncatedChunkHeader, PNG.LexingError.truncatedChunkBody {
            stream.reset(position: position)
            continue
        }
    }
}

// swiftlint:disable:next cyclomatic_complexity function_body_length
func decodeOnline(
    stream: inout SourceStream,
    overdraw: Bool,
    capture: (PNG.Image) throws -> Void
) throws -> PNG.Image {
    // lex PNG signature bytes
    try waitSignature(stream: &stream)
    // lex header chunk, and preceding cgbi chunk, if present
    let (standard, header): (PNG.Standard, PNG.Header) = try {
        var chunk: (type: PNG.Chunk, data: [UInt8]) = try waitChunk(stream: &stream)
        let standard: PNG.Standard
        switch chunk.type {
        case .CgBI:
            standard    = .ios
            chunk       = try waitChunk(stream: &stream)
        default:
            standard    = .common
        }
        switch chunk.type {
        case .IHDR:
            return (standard, try PNG.Header(parsing: chunk.data, standard: standard))
        default:
            fatalError("missing image header")
        }
    }()

    var chunk: (type: PNG.Chunk, data: [UInt8]) = try waitChunk(stream: &stream)

    var context: PNG.Context = try {
        var palette: PNG.Palette?
        var background: PNG.Background?
        var transparency: PNG.Transparency?
        var metadata = PNG.Metadata()
        while true {
            switch chunk.type {
            case .PLTE:
                guard   palette             == nil,
                        background          == nil,
                        transparency        == nil
                else {
                    fatalError("invalid chunk ordering")
                }
                palette = try .init(parsing: chunk.data, pixel: header.pixel)
            case .IDAT:
                guard let context = PNG.Context(
                    standard: standard,
                    header: header,
                    palette: palette,
                    background: background,
                    transparency: transparency,
                    metadata: metadata,
                    uninitialized: false)
                else {
                    fatalError("missing palette")
                }
                return context
            case .IHDR, .IEND:
                fatalError("unexpected chunk")
            default:
                try metadata.push(ancillary: chunk, pixel: header.pixel,
                    palette: palette,
                    background: &background,
                    transparency: &transparency)
            }
            chunk = try waitChunk(stream: &stream)
        }
    }()

    while chunk.type == .IDAT {
        try context.push(data: chunk.data, overdraw: overdraw)
        try capture(context.image)
        chunk = try waitChunk(stream: &stream)
    }

    while true {
        try context.push(ancillary: chunk)
        guard chunk.type != .IEND else {
            return context.image
        }
        chunk = try stream.chunk()
    }
}
