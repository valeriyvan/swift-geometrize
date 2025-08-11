import Foundation
import Geometrize
import PNG
import Algorithms

public extension BitmapG where ColorType == Rgba8888 {

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
        self = BitmapG(width: image.size.x, height: image.size.y, data: data, blending: .white)
    }

}

// TODO: this should not rely on RGBAccessible
public extension BitmapG where ColorType: RGBAccessible {
    
    func pngData() throws -> Data {
        // Convert to RGBA8888 first
        let rgba8888Bitmap = BitmapG<Rgba8888>(width: width, height: height) { x, y in
            let sourceColor = self[x, y]
            return Rgba8888(r: sourceColor.r, g: sourceColor.g, b: sourceColor.b, a: 255)
        }
        return try rgba8888Bitmap.pngData()
    }
    
}
