import Foundation

// Helper class for working with bitmap data.
// Pixels are ordered line by line, like arrays in C.

public struct Bitmap {
    
    // Creates useless empty bitmap.
    public init() {
        width = 0
        height = 0
        backing = ContiguousArray<UInt8>()
    }
    
    // Creates a new bitmap.
    // @param width The width of the bitmap.
    // height The height of the bitmap.
    // @param color The starting color of the bitmap (RGBA format).
    public init(width: Int, height: Int, color: Rgba) {
        assert(width >= 0 && height >= 0)
        self.width = width
        self.height = height
        let pixelCount = width * height
        let capacity =  pixelCount * 4
        backing = ContiguousArray<UInt8>(unsafeUninitializedCapacity: capacity) { buffer, initializedCapacity in
            for index in 0 ..< pixelCount {
                let offset = index * 4
                buffer[offset + 0] = color.r
                buffer[offset + 1] = color.g
                buffer[offset + 2] = color.b
                buffer[offset + 3] = color.a
            }
            initializedCapacity = capacity
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
        self.backing = ContiguousArray(data)
    }

    public init(width: Int, height: Int, initializer: (_: Int, _: Int) -> Rgba) {
        assert(width > 0 && height > 0)
        self.width = width
        self.height = height
        self.backing = ContiguousArray.init(unsafeUninitializedCapacity: width * height * 4) {
            buffer, initializedCapacity in
            for y in 0..<height {
                for x in 0..<width {
                    let rgba = initializer(x, y)
                    let offset = (width * y + x) * 4
                    buffer[offset + 0] = rgba.r
                    buffer[offset + 1] = rgba.g
                    buffer[offset + 2] = rgba.b
                    buffer[offset + 3] = rgba.a
                }
            }
            initializedCapacity = width * height * 4
        }
    }
    
    // Width of the bitmap.
    public private(set) var width: Int

    @inlinable
    @inline(__always)
    public var widthIndices: Range<Int> { 0..<width }

    // Height of the bitmap.
    public private(set) var height: Int

    @inlinable
    @inline(__always)
    public var heightIndices: Range<Int> { 0..<height }

    @inlinable
    @inline(__always)
    public var pixelCount: Int { width * height }
    
    @inlinable
    @inline(__always)
    public var componentCount: Int { pixelCount * 4 }

    // Raw bitmap data.
    public private(set) var backing: ContiguousArray<UInt8> // C ordering, row by row

    // Bitmap has no pixels.
    @inlinable
    @inline(__always)
    public var isEmpty: Bool { width == 0 || height == 0 }

    public subscript(x: Int, y: Int) -> Rgba {
        // Gets a pixel color value.
        // @param x The x-coordinate of the pixel.
        // @param y The y-coordinate of the pixel.
        // @return The pixel RGBA color value.
        get {
            backing.withUnsafeBufferPointer {
                let offset = offset(x: x, y: y)
                return Rgba(r: $0[offset], g: $0[offset + 1], b: $0[offset + 2], a: $0[offset + 3])
            }
        }
        // Sets a pixel color value.
        // @param x The x-coordinate of the pixel.
        // @param y The y-coordinate of the pixel.
        // @param color The pixel RGBA color value.
        set {
            let offset = offset(x: x, y: y)
            backing.withUnsafeMutableBufferPointer {
                $0[offset + 0] = newValue.r
                $0[offset + 1] = newValue.g
                $0[offset + 2] = newValue.b
                $0[offset + 3] = newValue.a
            }

        }
    }

    public subscript(_ point: Point<Int>) -> Rgba {
        get {
            self[point.x, point.y]
        }
        set {
            self[point.x, point.y] = newValue
        }
    }

    // Fills the bitmap with the given color.
    // @param color The color to fill the bitmap with.
    public mutating func fill(color: Rgba) {
        let count = pixelCount
        backing.withUnsafeMutableBufferPointer {
            for index in 0 ..< count {
                let offset = index * 4
                $0[offset + 0] = color.r
                $0[offset + 1] = color.g
                $0[offset + 2] = color.b
                $0[offset + 3] = color.a
            }
        }
    }
    
    @inlinable
    @inline(__always)
    internal func offset(x: Int, y: Int) -> Int {
        assert(0..<width ~= x && 0..<height ~= y)
        return (width * y + x) * 4
    }
    
    public mutating func addFrame(width inset: Int, color: Rgba) {
        assert(inset >= 0)
        guard inset > 0 else { return }
        let newWidth = width + inset * 2
        let newHeight = height + inset * 2
        let newCapacity = newWidth * newHeight * 4
        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: newCapacity) { buffer, initializedCapacity in
            for x in 0..<newWidth {
                for y in 0..<newHeight {
                    let targetOffset =  (newWidth * y + x) * 4
                    if (inset..<newWidth-inset ~= x) && (inset..<newHeight-inset ~= y) {
                        let sourceOffset = (width * (y - inset) + (x - inset)) * 4
                        for i in 0..<4 {
                            buffer[targetOffset + i] = backing[sourceOffset + i] // TODO: withUnsafeBufferPointer
                        }
                    } else {
                        buffer[targetOffset + 0] = color.r
                        buffer[targetOffset + 1] = color.g
                        buffer[targetOffset + 2] = color.b
                        buffer[targetOffset + 3] = color.a
                    }
                }
            }
            initializedCapacity = newCapacity
        }
        width = newWidth
        height = newHeight
        backing = newBacking
    }

}

extension Bitmap: Equatable {
    public static func == (lhs: Bitmap, rhs: Bitmap) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height && lhs.backing == rhs.backing
    }
}

extension Bitmap {
    
    // Computes the average RGB color of the pixels in the bitmap.
    // @return The average RGB color of the image, RGBA8888 format. Alpha is set to opaque (255).
    // TODO: carefully check implementation for overflows.
    // TODO: make it internal
    public func averageColor() -> Rgba {
        guard !isEmpty else { return .black }

        var totalRed: Int = 0
        var totalGreen: Int = 0
        var totalBlue: Int = 0
        backing.withUnsafeBufferPointer {
            for i in stride(from: 0, to: $0.count, by: 4) {
                totalRed += Int($0[i])
                totalGreen += Int($0[i + 1])
                totalBlue += Int($0[i + 2])
            }
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

extension Bitmap {
    
    // Draws scanlines onto an image.
    // @param color The color of the scanlines.
    // @param lines The scanlines to draw.
    mutating func draw(lines: [Scanline], color: Rgba) {
        // Convert the non-premultiplied color to alpha-premultiplied 16-bits per channel RGBA
        // In other words, scale the rgb color components by the alpha component
        var sr: UInt32 = UInt32(color.r)
        sr |= sr << 8
        sr *= UInt32(color.a)
        sr /= UInt32(UInt8.max)
        var sg: UInt32 = UInt32(color.g)
        sg |= sg << 8
        sg *= UInt32(color.a)
        sg /= UInt32(UInt8.max)
        var sb: UInt32 = UInt32(color.b)
        sb |= sb << 8
        sb *= UInt32(color.a)
        sb /= UInt32(UInt8.max)
        var sa: UInt32 = UInt32(color.a)
        sa |= sa << 8

        let m: UInt32 = UInt32(UInt16.max)
        let aa: UInt32 = (m - sa) * 257

        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                let d: Rgba = self[x, Int(y)]
                let r: UInt8 = UInt8(((UInt32(d.r) * aa + sr * m) / m) >> 8)
                let g: UInt8 = UInt8(((UInt32(d.g) * aa + sg * m) / m) >> 8)
                let b: UInt8 = UInt8(((UInt32(d.b) * aa + sb * m) / m) >> 8)
                let a: UInt8 = UInt8(((UInt32(d.a) * aa + sa * m) / m) >> 8)
                self[x, y] = Rgba(r: r, g: g, b: b, a: a)
            }
        }

    }

    // Copies source pixels to a destination defined by a set of scanlines.
    // @param destination The destination bitmap to copy the lines to.
    // @param source The source bitmap to copy the lines from.
    // @param lines The scanlines that comprise the source to destination copying mask.
    mutating func copy(lines: [Scanline], source: Bitmap) {
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                self[x, y] = source[x, y]
            }
        }
    }

}

// TODO: what's right way to implement this init as failable or throwing?
// One hints is here https://forums.swift.org/t/how-to-make-expressiblebystringliteral-init-either-failable-somehow-or-throws/47973/3:

extension Bitmap: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        let scanner = Scanner(string: value)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines
        guard
            scanner.scanString("width:") != nil,
            let width = scanner.scanInt(), width > 0,
            scanner.scanString(",") != nil,
            scanner.scanString("height:") != nil,
            let height = scanner.scanInt(), height > 0
        else {
            fatalError()
        }
        self.width = width
        self.height = height
        backing = ContiguousArray<UInt8>(repeating: 0, count: width * height * 4)
        
        var counter: Int = 0
        
        repeat {
            guard let int = scanner.scanInt(), 0...255 ~= int else {
                fatalError()
            }
            backing[counter] = UInt8(int)
            counter += 1
        } while scanner.scanString(",") != nil
        
        guard counter == width * height * 4 else {
            fatalError()
        }
    }
    
}

extension Bitmap: CustomStringConvertible {
    
    public var description: String {
        "width: \(width), height: \(height)\n" + backing.map(String.init).joined(separator: ",")
    }
    
}
