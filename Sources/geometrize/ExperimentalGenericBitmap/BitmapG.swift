import Foundation

/// Generic bitmap of Color pixels.
/// Pixels are ordered line by line, like arrays in C.
public struct BitmapG<ColorType: Color>: Sendable {

    /// Creates useless empty bitmap.
    public init() {
        width = 0
        height = 0
        backing = ContiguousArray<UInt8>()
    }

    /// Creates a new bitmap.
    /// - Parameters:
    ///   - width: The width of the bitmap.
    ///   - height: The height of the bitmap.
    ///   - color: The starting color of the bitmap.
    public init(width: Int, height: Int, color: ColorType) {
        assert(width >= 0 && height >= 0)
        self.width = width
        self.height = height
        let pixelCount = width * height
        let capacity = pixelCount * ColorType.totalSize
        backing = ContiguousArray<UInt8>(unsafeUninitializedCapacity: capacity) { buffer, initializedCapacity in
            for index in 0 ..< pixelCount {
                let offset = index * ColorType.totalSize
                color.write(to: buffer, at: offset)
            }
            initializedCapacity = capacity
        }
    }

    /// Creates a new bitmap from the supplied byte data.
    /// - Parameters:
    ///   - width: The width of the bitmap.
    ///   - height: The height of the bitmap.
    ///   - data: The byte data to fill the bitmap with, must be width * height * ColorType.totalSize long.
    ///   - blending: Background color to be blended. If nil, data provided is used as is.
    ///   If not nil, background is blended into bitmap making it opaque, alpha of background itself is ignored.
    public init(width: Int, height: Int, data: ContiguousArray<UInt8>, blending background: ColorType? = nil) {
        assert(width > 0 && height > 0)
        assert(width * height * ColorType.totalSize == data.count)
        self.width = width
        self.height = height
        if let background {
            self.backing = ContiguousArray(unsafeUninitializedCapacity: width * height * ColorType.totalSize) {
                buffer, initializedCapacity in
                for y in 0..<height {
                    for x in 0..<width {
                        let offset = (width * y + x) * ColorType.totalSize
                        let color = data.withUnsafeBufferPointer { buffer in
                            ColorType(from: buffer, at: offset)
                        }
                        let blendedColor = color.blending(background: background)
                        blendedColor.write(to: buffer, at: offset)
                    }
                }
                initializedCapacity = width * height * ColorType.totalSize
            }
        } else {
            self.backing = data
        }
    }

    public init(width: Int, height: Int, data: [UInt8], blending background: ColorType? = nil) {
        self = BitmapG(width: width, height: height, data: ContiguousArray(data), blending: background)
    }

    public init(width: Int, height: Int, initializer: (_: Int, _: Int) -> ColorType) {
        assert(width > 0 && height > 0)
        self.width = width
        self.height = height
        self.backing = ContiguousArray(unsafeUninitializedCapacity: width * height * ColorType.totalSize) {
            buffer, initializedCapacity in
            for y in 0..<height {
                for x in 0..<width {
                    let color = initializer(x, y)
                    let offset = (width * y + x) * ColorType.totalSize
                    color.write(to: buffer, at: offset)
                }
            }
            initializedCapacity = width * height * ColorType.totalSize
        }
    }

    /// Width of the bitmap.
    public internal(set) var width: Int

    @inlinable
    @inline(__always)
    public var widthIndices: Range<Int> { 0..<width }

    /// Height of the bitmap.
    public internal(set) var height: Int

    @inlinable
    @inline(__always)
    public var heightIndices: Range<Int> { 0..<height }

    @inlinable
    @inline(__always)
    public var pixelCount: Int { width * height }

    @inlinable
    @inline(__always)
    public var componentCount: Int { pixelCount * ColorType.totalSize }

    /// Raw bitmap data.
    public internal(set) var backing: ContiguousArray<UInt8>

    /// Bitmap has no pixels.
    @inlinable
    @inline(__always)
    public var isEmpty: Bool { width == 0 || height == 0 }

    @inlinable
    @inline(__always)
    public func isInBounds(x: Int, y: Int) -> Bool {
        x >= 0 && x < width && y >= 0 && y < height
    }

    @inlinable
    @inline(__always)
    public func isInBounds(_ point: Point<Int>) -> Bool {
        point.x >= 0 && point.x < width && point.y >= 0 && point.y < height
    }

    public subscript(x: Int, y: Int) -> ColorType {
        get {
            backing.withUnsafeBufferPointer { buffer in
                let offset = offset(x: x, y: y)
                return ColorType(from: buffer, at: offset)
            }
        }
        set {
            let offset = offset(x: x, y: y)
            backing.withUnsafeMutableBufferPointer { buffer in
                newValue.write(to: buffer, at: offset)
            }
        }
    }

    public subscript(_ point: Point<Int>) -> ColorType {
        get {
            self[point.x, point.y]
        }
        set {
            self[point.x, point.y] = newValue
        }
    }

    /// Fills the bitmap with the given color.
    /// - Parameter color: The color to fill the bitmap with.
    public mutating func fill(color: ColorType) {
        let count = pixelCount
        backing.withUnsafeMutableBufferPointer { buffer in
            for index in 0 ..< count {
                let offset = index * ColorType.totalSize
                color.write(to: buffer, at: offset)
            }
        }
    }

    @inlinable
    @inline(__always)
    internal func offset(x: Int, y: Int) -> Int {
        assert(0..<width ~= x && 0..<height ~= y)
        return (width * y + x) * ColorType.totalSize
    }

    public mutating func addFrame(width inset: Int, color: ColorType) {
        assert(inset >= 0)
        guard inset > 0 else { return }
        let newWidth = width + inset * 2
        let newHeight = height + inset * 2
        let newCapacity = newWidth * newHeight * ColorType.totalSize
        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: newCapacity) {
            buffer, initializedCapacity in
            for y in 0..<newHeight {
                for x in 0..<newWidth {
                    let targetOffset = (newWidth * y + x) * ColorType.totalSize
                    if (inset..<newWidth-inset ~= x) && (inset..<newHeight-inset ~= y) {
                        let sourceOffset = (width * (y - inset) + (x - inset)) * ColorType.totalSize
                        backing.withUnsafeBufferPointer { source in
                            for i in 0..<ColorType.totalSize {
                                buffer[targetOffset + i] = source[sourceOffset + i]
                            }
                        }
                    } else {
                        color.write(to: buffer, at: targetOffset)
                    }
                }
            }
            initializedCapacity = newCapacity
        }
        width = newWidth
        height = newHeight
        backing = newBacking
    }

    public func downsample(factor: Int) -> BitmapG {
        assert(factor > 0)
        guard factor > 1 else { return self }
        let downsampledWidth = width / factor
        let downsampledHeight = height / factor
        let origin = self
        return BitmapG(width: downsampledWidth, height: downsampledHeight) { x, y in
            BitmapG(width: factor, height: factor) { sampleX, sampleY in
                origin[x * factor + sampleX, y * factor + sampleY]
            }
            .averageColor()
        }
    }

    mutating func transpose() {
        self = BitmapG(width: height, height: width) { x, y in
            self[y, x]
        }
    }

    mutating func swap(x1: Int, y1: Int, x2: Int, y2: Int) {
        assert(isInBounds(x: x1, y: y1) && isInBounds(x: x2, y: y2),
            "Swap coordinates must be within bitmap bounds")

        let offset1 = offset(x: x1, y: y1)
        let offset2 = offset(x: x2, y: y2)

        guard offset1 != offset2 else { return }

        backing.withUnsafeMutableBufferPointer { buffer in
            for i in 0..<ColorType.totalSize {
                let temp = buffer[offset1 + i]
                buffer[offset1 + i] = buffer[offset2 + i]
                buffer[offset2 + i] = temp
            }
        }
    }

    mutating func reflectVertically() {
        guard width > 1 else { return }

        backing.withUnsafeMutableBufferPointer { buffer in
            for y in 0 ..< height {
                let rowBase = y * width * ColorType.totalSize
                for x in 0 ..< width / 2 {
                    let offset1 = rowBase + x * ColorType.totalSize
                    let offset2 = rowBase + (width - x - 1) * ColorType.totalSize
                    for i in 0..<ColorType.totalSize {
                        let temp = buffer[offset1 + i]
                        buffer[offset1 + i] = buffer[offset2 + i]
                        buffer[offset2 + i] = temp
                    }
                }
            }
        }
    }

    mutating func reflectHorizontally() {
        guard height > 1 else { return }

        backing.withUnsafeMutableBufferPointer { buffer in
            for x in 0 ..< width {
                for y in 0 ..< height / 2 {
                    let offset1 = (y * width + x) * ColorType.totalSize
                    let offset2 = ((height - y - 1) * width + x) * ColorType.totalSize
                    for i in 0..<ColorType.totalSize {
                        let temp = buffer[offset1 + i]
                        buffer[offset1 + i] = buffer[offset2 + i]
                        buffer[offset2 + i] = temp
                    }
                }
            }
        }
    }
}

extension BitmapG: Equatable {
    public static func == (lhs: BitmapG, rhs: BitmapG) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height && lhs.backing == rhs.backing
    }
}

extension BitmapG {
    /// Computes the average color of the pixels in the bitmap.
    /// - Returns: The average color of the image.
    public func averageColor() -> ColorType {
        guard !isEmpty else { return ColorType.black }
        
        var colors: [ColorType] = []
        colors.reserveCapacity(pixelCount)
        
        for y in 0..<height {
            for x in 0..<width {
                colors.append(self[x, y])
            }
        }
        
        return ColorType.average(of: colors)
    }
    
    /// Returns opaque image with blended background.
    /// Background alpha is ignored.
    public func blending(background: ColorType) -> BitmapG<ColorType> {
        BitmapG(width: width, height: height) { x, y in
            self[x, y].blending(background: background)
        }
    }

    /// Compares this bitmap with another bitmap using precision threshold.
    /// - Parameters:
    ///   - other: The bitmap to compare with
    ///   - precision: Precision threshold (0.0 to 1.0)
    /// - Returns: True if bitmaps are similar within precision threshold
    public func compare(with other: BitmapG<ColorType>, precision: Double) -> Bool {
        guard width != 0 else { return false }
        guard other.width != 0 else { return false }
        guard width == other.width else { return false }
        guard height != 0 else { return false }
        guard other.height != 0 else { return false }
        guard height == other.height else { return false }
        var differentPixelCount = 0
        let threshold = 1 - precision
        let componentCount = Double(componentCount)
        for y in heightIndices {
            for x in widthIndices {
                if self[x, y] != other[x, y] {
                    if precision >= 0 { return false }
                    differentPixelCount += 1
                }
                if Double(differentPixelCount) / Double(componentCount) > threshold { return false }
            }
        }
        return true
    }
}
