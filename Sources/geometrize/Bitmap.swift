import Foundation

/// Helper for working with bitmap data.
/// Pixels are ordered line by line, like arrays in C.
public struct Bitmap: Sendable { // swiftlint:disable:this type_body_length

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
    ///   - color: The starting color of the bitmap (RGBA format).
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

    /// Creates a new bitmap from the supplied byte data.
    /// - Parameters:
    ///   - width: The width of the bitmap.
    ///   - height: The height of the bitmap.
    ///   - data: The byte data to fill the bitmap with, must be width * height * depth (4) long.
    ///   - blending: Background color to be blended. If nil, data provided is used as is.
    ///   If not nil,  background is blended into bitmap making it opaque (alpha 255), alpha of background itself is ignored.
    public init(width: Int, height: Int, data: ContiguousArray<UInt8>, blending background: Rgba? = nil) {
        assert(width > 0 && height > 0)
        assert(width * height * 4 == data.count)
        self.width = width
        self.height = height
        if let background {
            self.backing = ContiguousArray(unsafeUninitializedCapacity: width * height * 4) {
                buffer, initializedCapacity in // swiftlint:disable:this closure_parameter_position
                for y in 0..<height {
                    for x in 0..<width {
                        let offset = (width * y + x) * 4
                        let rgba = Rgba(data[offset..<offset+4]).blending(background: background)
                        buffer[offset + 0] = rgba.r
                        buffer[offset + 1] = rgba.g
                        buffer[offset + 2] = rgba.b
                        buffer[offset + 3] = rgba.a
                    }
                }
                initializedCapacity = width * height * 4
            }
        } else {
            self.backing = data
        }
    }

    public init(width: Int, height: Int, data: [UInt8], blending background: Rgba? = nil) {
        self = Bitmap(width: width, height: height, data: ContiguousArray(data), blending: background)
    }

    public init(width: Int, height: Int, initializer: (_: Int, _: Int) -> Rgba) {
        assert(width > 0 && height > 0)
        self.width = width
        self.height = height
        self.backing = ContiguousArray(unsafeUninitializedCapacity: width * height * 4) {
            buffer, initializedCapacity in // swiftlint:disable:this closure_parameter_position
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

    /// Width of the bitmap.
    public private(set) var width: Int

    @inlinable
    @inline(__always)
    public var widthIndices: Range<Int> { 0..<width }

    /// Height of the bitmap.
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

    /// Raw bitmap data.
    public private(set) var backing: ContiguousArray<UInt8> // C ordering, row by row

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

    public subscript(x: Int, y: Int) -> Rgba {
        get {
            backing.withUnsafeBufferPointer { buffer in
                let offset = offset(x: x, y: y)
                return Rgba(buffer[offset..<offset + 4])
            }
        }
        set {
            let offset = offset(x: x, y: y)
            backing.withUnsafeMutableBufferPointer { buffer in
                buffer[offset + 0] = newValue.r
                buffer[offset + 1] = newValue.g
                buffer[offset + 2] = newValue.b
                buffer[offset + 3] = newValue.a
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

    /// Fills the bitmap with the given color.
    /// - Parameter color: The color to fill the bitmap with.
    public mutating func fill(color: Rgba) {
        let count = pixelCount
        backing.withUnsafeMutableBufferPointer { buffer in
            for index in 0 ..< count {
                let offset = index * 4
                buffer[offset + 0] = color.r
                buffer[offset + 1] = color.g
                buffer[offset + 2] = color.b
                buffer[offset + 3] = color.a
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
        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: newCapacity) {
            buffer, initializedCapacity in // swiftlint:disable:this closure_parameter_position
            for y in 0..<newHeight {
                for x in 0..<newWidth {
                    let targetOffset =  (newWidth * y + x) * 4
                    if (inset..<newWidth-inset ~= x) && (inset..<newHeight-inset ~= y) {
                        let sourceOffset = (width * (y - inset) + (x - inset)) * 4
                        backing.withUnsafeBufferPointer { source in
                            buffer[targetOffset + 0] = source[sourceOffset + 0]
                            buffer[targetOffset + 1] = source[sourceOffset + 1]
                            buffer[targetOffset + 2] = source[sourceOffset + 2]
                            buffer[targetOffset + 3] = source[sourceOffset + 3]
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

    // Primitive downsample algorithm utilising Bitmap's averageColor function.
    public func downsample(factor: Int) -> Bitmap {
        assert(factor > 0)
        guard factor > 1 else { return self }
        let downsampledWidth = width / factor
        let downsampledHeight = height / factor
        let origin = self
        return Bitmap(width: downsampledWidth, height: downsampledHeight) { x, y in
            Bitmap(width: factor, height: factor) { sampleX, sampleY in
                origin[x * factor + sampleX, y * factor + sampleY]
            }
            .averageColor()
        }
    }

    // Transposes Bitmap
    mutating func transpose() {
        self = Bitmap(width: height, height: width) { x, y in
            self[y, x]
        }
    }

    // Swaps points (x1, y1) and (x2, y2)
    // TODO: optimize
    mutating func swap(x1: Int, y1: Int, x2: Int, y2: Int) {
        let copy = self[x1, y1]
        self[x1, y1] = self[x2, y2]
        self[x2, y2] = copy
    }

    // Reflects bitmap around vertical axis
    // TODO: optimize
    mutating func reflectVertically() {
        for x in 0 ..< width / 2 {
            for y in 0 ..< height {
                swap(x1: x, y1: y, x2: width - x - 1, y2: y)
            }
        }
    }

    // Reflects bitmap around horizontal axis
    // TODO: optimize
    mutating func reflectHorizontally() {
        for x in 0 ..< width {
            for y in 0 ..< height / 2 {
                swap(x1: x, y1: y, x2: x, y2: height - y - 1)
            }
        }
    }

    // TODO: is it possible to do in place?
    private mutating func reflectDown() {
        self = Bitmap(width: width, height: height) { x, y in
            self[width - x - 1, height - y - 1]
        }
    }

    private mutating func reflectLeftMirrored() {
        self = Bitmap(width: height, height: width) { x, y in
            self[y, x]
        }
    }

    private mutating func reflectLeft() {
        self = Bitmap(width: height, height: width) { x, y in
            self[y, height - x - 1]
        }
    }

    private mutating func reflectRightMirrored() {
        self = Bitmap(width: height, height: width) { x, y in
            self[width - y - 1, height - x - 1]
        }
    }

    private mutating func reflectRight() {
        self = Bitmap(width: height, height: width) { x, y in
            self[width - y - 1, x]
        }
    }

    // https://home.jeita.or.jp/tsc/std-pdf/CP3451C.pdf, page 30
    public enum ExifOrientation: Int {
        // 1 The Oth row is at the visual top of the image, and the 0th column is the visual left-hand side.
        case up = 1
        // 2 The Oth row is at the visual top of the image, and the Oth column is the visual right-hand side.
        case upMirrored = 2
        // 3 The Oth row is at the visual bottom of the image, and the Oth column is the visual right-hand side.
        case down = 3
        // 4 The Oth row is at the visual bottom of the image, and the 0th column is the visual left-hand side.
        case downMirrored = 4
        // 5 The Oth row is the visual left-hand side of the image, and the 0th column is the visual top.
        case leftMirrored = 5
        // 6 The Oth row is the visual right-hand side of the image, and the 0th column is the visual top.
        case left = 6
        // 7 The Oth row is the visual right-hand side of the image, and the 0th column is the visual bottom.
        case rightMirrored = 7
        // 8 The Oth row is the visual left-hand side of the image, and the 0th column is the visual bottom.
        case right = 8
    }

    public mutating func rotateToUpOrientation(accordingTo orientation: ExifOrientation) {
        switch orientation {
        case .up:
            ()
        case .upMirrored:
            reflectVertically()
        case .down:
            reflectDown()
        case .downMirrored:
            reflectHorizontally()
        case .leftMirrored:
            reflectLeftMirrored()
        case .left:
            reflectLeft()
        case .rightMirrored:
            reflectRightMirrored()
        case .right:
            reflectRight()
        }
    }
}

extension Bitmap: Equatable {
    public static func == (lhs: Bitmap, rhs: Bitmap) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height && lhs.backing == rhs.backing
    }
}

extension Bitmap {

    /// Computes the average RGB color of the pixels in the bitmap.
    /// - Returns: The average RGB color of the image, RGBA8888 format. Alpha is set to opaque (255).
    public func averageColor() -> Rgba {
        // TODO: carefully check implementation for overflows.
        // TODO: make it internal
        guard !isEmpty else { return .black }

        var totalRed: Int = 0
        var totalGreen: Int = 0
        var totalBlue: Int = 0
        backing.withUnsafeBufferPointer { buffer in
            for i in stride(from: 0, to: buffer.count, by: 4) {
                totalRed += Int(buffer[i])
                totalGreen += Int(buffer[i + 1])
                totalBlue += Int(buffer[i + 2])
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

    // Returns opaque (alpha 255) image with blended background.
    // Alpha of background itself is ignored.
    public func blending(background: Rgba) -> Bitmap {
        Bitmap(width: width, height: height) { x, y in
            self[x, y].blending(background: background)
        }
    }

}

extension Bitmap {

    /// Draws scanlines onto an image.
    /// - Parameters:
    ///   - lines: The color of the scanlines.
    ///   - color: The scanlines to draw.
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

    /// Copies source pixels defined by a set of scanlines.
    /// - Parameters:
    ///   - lines: The scanlines that comprise the source to destination copying mask.
    ///   - source: The source bitmap to copy the lines from.
    mutating func copy(lines: [Scanline], source: Bitmap) {
        for line in lines {
            let y = line.y
            for x in line.x1...line.x2 {
                self[x, y] = source[x, y]
            }
        }
    }

}

extension Bitmap {

    public enum ParsePpmError: Error {
        case noP3
        case inconsistentHeader(String)
        case maxElementNot255(String)
        case wrongElement(String)
        case excessiveCharacters(String)
    }

    // Format is described in https://en.wikipedia.org/wiki/Netpbm and https://netpbm.sourceforge.net/doc/ppm.html
    public init(ppmString string: String) throws {
        var stringWithTrimmedComments = ""
        string.enumerateLines { line, _ in
            let endIndex = line.firstIndex(of: "#") ?? line.endIndex
            stringWithTrimmedComments.append(line[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines))
            stringWithTrimmedComments.append(" ")
        }
        let scanner = Scanner(string: stringWithTrimmedComments)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines
        guard scanner.scanString("P3") != nil else {
            throw ParsePpmError.noP3
        }
        guard let width = scanner.scanInt(), width > 0, let height = scanner.scanInt(), height > 0 else {
            throw ParsePpmError.inconsistentHeader(String(string[..<scanner.currentIndex]))
        }
        guard let maxValue = scanner.scanInt(), maxValue == 255
        else {
            throw ParsePpmError.maxElementNot255(String(string[..<scanner.currentIndex]))
        }
        self.width = width
        self.height = height
        let capacity = width * height * 4
        self.backing = try ContiguousArray<UInt8>(unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
            var counter: Int = 0
            repeat {
                let startIndex = scanner.currentIndex
                guard
                    let red = scanner.scanInt(), 0...255 ~= red,
                    let green = scanner.scanInt(), 0...255 ~= green,
                    let blue = scanner.scanInt(), 0...255 ~= blue
                else {
                    let context = String(string[startIndex..<scanner.currentIndex])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    throw ParsePpmError.wrongElement(context)
                }
                buffer[counter] = UInt8(red)
                counter += 1
                buffer[counter] = UInt8(green)
                counter += 1
                buffer[counter] = UInt8(blue)
                counter += 1
                buffer[counter] = 255
                counter += 1
            } while counter < capacity

            let startIndex = scanner.currentIndex
            guard scanner.isAtEnd else {
                let context = String(string[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                throw ParsePpmError.excessiveCharacters(context)
            }
            initializedCount = capacity
        }
    }

    public func ppmString(background: Rgba = .white) -> String {
        """
        P3
        \(width) \(height)
        255

        """
        +
        backing
            // .lazy ???
            .chunks(ofCount: 4)
            .map { Rgba($0).blending(background: background).asArray.dropLast() }
            .compactMap { $0.map(String.init).joined(separator: " ") + "\n" }
            .joined()
    }

    public var ppmString: String { ppmString() }
}

extension Bitmap {

    // swiftlint:disable:next cyclomatic_complexity
    public func compare(with other: Bitmap, precision: Double) -> Bool {
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

// swiftlint:disable:this file_length
