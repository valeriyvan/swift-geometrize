import Foundation

#if canImport(UIKit)

import UIKit

extension Bitmap {

    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else { return nil }

        // Redraw image for correct pixel format

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let size = width * height
        let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        defer { imageData.deallocate() }

        guard let imageContext = CGContext(
            data: imageData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        imageContext.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        let bufferPointer = UnsafeMutableBufferPointer<UInt8>(start: imageData, count: size)

        self.init(width: width, height: height, data: Array(bufferPointer))
    }

    public func uiImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue |
            CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        var mutableBacking = backing
        return mutableBacking.withUnsafeMutableBufferPointer {
            CGContext(
                data: $0.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                releaseCallback: nil,
                releaseInfo: nil
            )?
            .makeImage()
            .flatMap(UIImage.init(cgImage:))
        }
    }
}

#endif
