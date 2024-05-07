import Foundation
import JPEG
import Geometrize

public extension Bitmap {

    /// Creates data of JPEG image
    /// - Parameters:
    ///   - blending: Background color to be blended. This has effect only if image has non opaque pixels (pixels with alpha less then 255).
    ///   Alpha of background itself is ignored.
    func jpegData(blending background: Rgba = .white) throws -> Data {
        let rgb: [JPEG.RGB] = backing
            //.lazy // TODO: make lazy work!
            .chunks(ofCount: 4)
            .map { Rgba($0).blending(background: background) }
            .map { JPEG.RGB($0.r, $0.g, $0.b) }

        let format: JPEG.Common = .ycc8

        let y: JPEG.Component.Key = format.components[0],
            cb: JPEG.Component.Key = format.components[1],
            cr: JPEG.Component.Key = format.components[2]

        let layout = JPEG.Layout<JPEG.Common>(
            format: format,
            process: .progressive(coding: .huffman, differential: false),
            components:
            [
                y: (factor: (2, 1), qi: 0), // 4:2:2 subsampling
                cb: (factor: (1, 1), qi: 1),
                cr: (factor: (1, 1), qi: 1)
            ],
            scans:
            [
                .progressive((y, \.0), (cb, \.1), (cr, \.1), bits: 2...),
                .progressive( y, cb, cr, bit: 1),
                .progressive( y, cb, cr, bit: 0),

                .progressive((y, \.0), band: 1..<64, bits: 1...),

                .progressive((cb, \.0), band: 1..<6, bits: 1...),
                .progressive((cr, \.0), band: 1..<6, bits: 1...),

                .progressive((cb, \.0), band: 6..<64, bits: 1...),
                .progressive((cr, \.0), band: 6..<64, bits: 1...),

                .progressive((y, \.0), band: 1..<64, bit: 0),
                .progressive((cb, \.0), band: 1..<64, bit: 0),
                .progressive((cr, \.0), band: 1..<64, bit: 0)
            ])

        let comment: [UInt8] = .init("Created with command line version of swift-geometrize https://github.com/valeriyvan/swift-geometrize".utf8)
        let rectangular: JPEG.Data.Rectangular<JPEG.Common>  =
            .pack(size: (x: width, y: height), layout: layout, metadata: [.comment(data: comment)], pixels: rgb)

        let planar: JPEG.Data.Planar<JPEG.Common> = rectangular.decomposed()
        let spectral: JPEG.Data.Spectral<JPEG.Common> = planar.fdct(quanta:
            [
                0: [1, 2, 2, 3, 3, 3] + .init(repeating: 4, count: 58),
                1: [1, 2, 2, 5, 5, 5] + .init(repeating: 30, count: 58)
            ]
        )

        var destinationStream = DestinationStream()
        try spectral.compress(stream: &destinationStream)
        return Data(destinationStream.data)
    }

    init(jpegData data: Data) throws {
        var sourceStream = SourceStream(data)
        let image: JPEG.Data.Rectangular<JPEG.Common> = try .decompress(stream: &sourceStream)
        let rgb: [JPEG.RGB] = image.unpack(as: JPEG.RGB.self)
        let (width, height) = image.size
        let rgba: [UInt8] = rgb.flatMap({ [$0.r, $0.g, $0.b, 255] })
        var bitmap = Bitmap(width: width, height: height, data: rgba)
        let exifOrientation = Bitmap.ExifOrientation(rawValue: image.exifOrientation()) ?? .up
        bitmap.rotateToUpOrientation(accordingTo: exifOrientation)
        self = bitmap
    }

    init(jpegUrl url: URL) throws {
        guard let image: JPEG.Data.Rectangular<JPEG.Common> = try .decompress(path: url.path) else {
            // decompress returns nil when file cannot be open
            throw NSError(domain: URLError.errorDomain, code: URLError.cannotOpenFile.rawValue)
        }
        let rgb: [JPEG.RGB] = image.unpack(as: JPEG.RGB.self)
        let data: [UInt8] = rgb.flatMap({ [$0.r, $0.g, $0.b, 255] })
        self = Bitmap(width: image.size.x, height: image.size.y, data: data)
    }

}
