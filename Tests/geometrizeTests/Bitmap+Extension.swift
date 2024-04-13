import XCTest
import PNG
import Algorithms
@testable import Geometrize

extension Bitmap {

    func pngData() throws -> Data {
        let rgba: [PNG.RGBA<UInt8>] = backing.chunks(ofCount: 4).map {
            PNG.RGBA(
                $0[$0.startIndex + 0],
                $0[$0.startIndex + 1],
                $0[$0.startIndex + 2],
                $0[$0.startIndex + 3]
            )
        }
        let image: PNG.Image = PNG.Image(packing: rgba, size: (x: width, y: height), layout: PNG.Layout(format: .rgba8(palette: [], fill: nil)))
        var destinationStream = DestinationStream()
        try image.compress(stream: &destinationStream)
        return Data(destinationStream.data)
    }

    init(pngData data: Data) throws {
        let bytes = data.withUnsafeBytes { rawBufferPointer in
            [UInt8](unsafeUninitializedCapacity: rawBufferPointer.count) { buffer, initializedCount in
                _ = buffer.initialize(from: rawBufferPointer)
                initializedCount = buffer.count
            }
        }
        var stream = SourceStream(bytes)
        let image: PNG.Image  = try decodeOnline(stream: &stream, overdraw: false) { _ in }
        let rgba: [PNG.RGBA<UInt8>] = image.unpack(as: PNG.RGBA<UInt8>.self)
        let bitmapData: [UInt8] = rgba.flatMap({ [$0.r, $0.g, $0.b, $0.a] })
        self.init(width: image.size.0, height: image.size.1, data: bitmapData)
    }

}

// Borrowed https://github.com/kelvin13/swift-png/blob/0800c123d29d132cab70a1d492fb18a7e4007380/examples/decode-online/main.swift

struct SourceStream {
    private(set) var data: [UInt8]
    var position: Int
    var available: Int
}

extension SourceStream: PNG.Bytestream.Source {
    init(_ data: [UInt8]) {
        self.data       = data
        self.position   = data.startIndex
        self.available  = data.startIndex
    }

    mutating func read(count: Int) -> [UInt8]? {
        guard position + count <= data.endIndex else { return nil }
        guard position + count < available else {
            available += 4096
            return nil
        }
        defer { position += count }
        return [UInt8](data[position ..< position + count])
    }

    mutating func reset(position: Int) {
        precondition(data.indices ~= position)
        self.position = position
    }
}

struct DestinationStream: PNG.Bytestream.Destination {

    private(set) var data: [UInt8] = []

    mutating func write(_ buffer: [UInt8]) -> Void? {
        data.append(contentsOf: buffer)
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
    // lex header chunk, and preceeding cgbi chunk, if present
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
            return (standard, try .init(parsing: chunk.data, standard: standard))
        default:
            fatalError("missing image header")
        }
    }()

    var chunk: (type: PNG.Chunk, data: [UInt8]) = try waitChunk(stream: &stream)

    var context: PNG.Context = try {
        var palette: PNG.Palette?
        var background: PNG.Background?,
            transparency: PNG.Transparency?
        var metadata: PNG.Metadata = .init()
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
                guard let context: PNG.Context = PNG.Context.init(
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
        guard chunk.type != .IEND
        else {
            return context.image
        }
        chunk = try stream.chunk()
    }
}
