import Foundation

// Helper class for working with bitmap data.
// Pixels are ordered line by line, like arrays in C.

public struct Bitmap {
    
    // Create useless empty bitmap.
    public init() {
        width = 0
        height = 0
        data = []
    }
    
    // Creates a new bitmap.
    // @param width The width of the bitmap.
    // height The height of the bitmap.
    // @param color The starting color of the bitmap (RGBA format).
    public init(width: Int, height: Int, color: Rgba) {
        assert(width > 0 && height > 0)
        self.width = width
        self.height = height
        data = [UInt8](unsafeUninitializedCapacity: width * height * 4) { buffer, initializedCapacity in
            for index in 0 ..< width * height {
                let offset = index * 4
                buffer[offset + 0] = color.r
                buffer[offset + 1] = color.g
                buffer[offset + 2] = color.b
                buffer[offset + 3] = color.a
            }
            initializedCapacity = width * height * 4
        }
    }
    
    // Creates a new bitmap from the supplied byte data.
    // width The width of the bitmap.
    // height The height of the bitmap.
    // @param data The byte data to fill the bitmap with, must be width * height * depth (4) long.
    public init(width: Int, height: Int, data: [UInt8]) {
        assert(width > 0 && height > 0)
        assert(width * height * 4 == data.count)
        self.width = width
        self.height = height
        self.data = data
    }

    // Width of the bitmap.
    public let width: Int

    // Height of the bitmap.
    public let height: Int

    public var pixelCount: Int { width * height }
    
    // Raw bitmap data.
    public var data: [UInt8]

    @inlinable
    @inline(__always)
    public var isEmpty: Bool { width == 0 && height == 0 }

    public subscript(x: Int, y: Int) -> Rgba {
        // Gets a pixel color value.
        // @param x The x-coordinate of the pixel.
        // @param y The y-coordinate of the pixel.
        // @return The pixel RGBA color value.
        @inlinable
        @inline(__always)
        get {
            let offset = offset(x: x, y: y)
            return Rgba(r: data[offset], g: data[offset + 1], b: data[offset + 2], a: data[offset + 3])
        }
        // Sets a pixel color value.
        // @param x The x-coordinate of the pixel.
        // @param y The y-coordinate of the pixel.
        // @param color The pixel RGBA color value.
        @inlinable
        @inline(__always)
        set {
            let offset = offset(x: x, y: y)
            data[offset + 0] = newValue.r
            data[offset + 1] = newValue.g
            data[offset + 2] = newValue.b
            data[offset + 3] = newValue.a
        }
    }

    // Fills the bitmap with the given color.
    // @param color The color to fill the bitmap with.
    public mutating func fill(color: Rgba) {
        for index in 0 ..< pixelCount {
            let offset = index * 4
            data[offset + 0] = color.r
            data[offset + 1] = color.g
            data[offset + 2] = color.b
            data[offset + 3] = color.a
        }

    }
    
    @inlinable
    @inline(__always)
    internal func offset(x: Int, y: Int) -> Int {
        assert(0..<width ~= x && 0..<height ~= y)
        return (width * y + x) * 4
    }

}

extension Bitmap: Equatable {}

extension Bitmap {
    
    // Computes the average RGB color of the pixels in the bitmap.
    // @return The average RGB color of the image, RGBA8888 format. Alpha is set to opaque (255).
    // TODO: carefully check implementation for overflows.
    func averageColor() -> Rgba {
        guard !isEmpty else { return .black }

        var totalRed: Int = 0
        var totalGreen: Int = 0
        var totalBlue: Int = 0
        for i in stride(from: 0, to: data.count, by: 4) {
            totalRed += Int(data[i])
            totalGreen += Int(data[i + 1])
            totalBlue += Int(data[i + 2])
        }
        
        let pixelCount = self.pixelCount
        return Rgba(
            r: UInt8(totalRed / pixelCount),
            g: UInt8(totalGreen / pixelCount),
            b: UInt8(totalBlue / pixelCount),
            a: 255
        )
    }

}
