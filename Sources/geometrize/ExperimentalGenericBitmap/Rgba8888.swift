import Foundation

/// Helper for manipulating RGBA8888 color data.
public struct Rgba8888: Color {
    
    public var r: UInt8 // The red component (0-255).
    public var g: UInt8 // The green component (0-255).
    public var b: UInt8 // The blue component (0-255).
    public var a: UInt8 // The alpha component (0-255).

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    public init(_ tuple: (r: UInt8, g: UInt8, b: UInt8, a: UInt8)) {
        self.r = tuple.r
        self.g = tuple.g
        self.b = tuple.b
        self.a = tuple.a
    }

    public init(_ array: [UInt8]) {
        assert(array.count == 4)
        self.r = array[0]
        self.g = array[1]
        self.b = array[2]
        self.a = array[3]
    }

    public init(_ array: ContiguousArray<UInt8>) {
        assert(array.count == 4)
        self.r = array[0]
        self.g = array[1]
        self.b = array[2]
        self.a = array[3]
    }

    public init(_ slice: ArraySlice<UInt8>) {
        assert(slice.count == 4)
        self.r = slice[slice.startIndex]
        self.g = slice[slice.startIndex + 1]
        self.b = slice[slice.startIndex + 2]
        self.a = slice[slice.startIndex + 3]
    }

    public init(_ buffer: UnsafeBufferPointer<UInt8>) {
        assert(buffer.count == 4)
        self.r = buffer[0]
        self.g = buffer[1]
        self.b = buffer[2]
        self.a = buffer[3]
    }

    public init(_ slice: Slice<UnsafeBufferPointer<UInt8>>) {
        assert(slice.count == 4)
        self.r = slice[slice.startIndex]
        self.g = slice[slice.startIndex + 1]
        self.b = slice[slice.startIndex + 2]
        self.a = slice[slice.startIndex + 3]
    }

    public func withAlphaComponent(_ alpha: UInt8) -> Rgba8888 {
        Rgba8888(r: r, g: g, b: b, a: alpha)
    }

    public var asArray: [UInt8] { [r, g, b, a] }

    public var asTuple: (UInt8, UInt8, UInt8, UInt8) { (r, g, b, a) }
}

// MARK: - Color Protocol Conformance

extension Rgba8888 {
    public static let componentCount = 4
    public static let componentSize = 1
    public static let totalSize = 4
    
    public init(from buffer: UnsafeBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        self.r = buffer[offset]
        self.g = buffer[offset + 1]
        self.b = buffer[offset + 2]
        self.a = buffer[offset + 3]
    }
    
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        buffer[offset] = r
        buffer[offset + 1] = g
        buffer[offset + 2] = b
        buffer[offset + 3] = a
    }
    
    public static var black: Rgba8888 { Rgba8888(r: 0, g: 0, b: 0, a: 255) }
    public static var white: Rgba8888 { Rgba8888(r: 255, g: 255, b: 255, a: 255) }
    public static var red: Rgba8888 { Rgba8888(r: 255, g: 0, b: 0, a: 255) }
    public static var green: Rgba8888 { Rgba8888(r: 0, g: 255, b: 0, a: 255) }
    public static var blue: Rgba8888 { Rgba8888(r: 0, g: 0, b: 255, a: 255) }
    public static var yellow: Rgba8888 { Rgba8888(r: 255, g: 255, b: 0, a: 255) }
    public static var magenta: Rgba8888 { Rgba8888(r: 255, g: 0, b: 255, a: 255) }
    public static var cyan: Rgba8888 { Rgba8888(r: 0, g: 255, b: 255, a: 255) }

    // Returns opaque (alpha 255) color with blended background.
    // Alpha of background itself is ignored.
    public func blending(background: Rgba8888) -> Rgba8888 {
        // https://stackoverflow.com/a/746937/942513
        let alpha: Double = Double(a) / 255.0
        let oneMinusAlpha: Double = 1.0 - alpha
        return Rgba8888(
            r: UInt8(Double(r) * alpha + oneMinusAlpha * Double(background.r)),
            g: UInt8(Double(g) * alpha + oneMinusAlpha * Double(background.g)),
            b: UInt8(Double(b) * alpha + oneMinusAlpha * Double(background.b)),
            a: 255
        )
    }
    
    public static func average(of colors: [Rgba8888]) -> Rgba8888 {
        guard !colors.isEmpty else { return .black }
        
        let count = UInt64(colors.count)
        var totalR: UInt64 = 0
        var totalG: UInt64 = 0
        var totalB: UInt64 = 0
        var totalA: UInt64 = 0
        
        for color in colors {
            totalR += UInt64(color.r)
            totalG += UInt64(color.g)
            totalB += UInt64(color.b)
            totalA += UInt64(color.a)
        }
        
        return Rgba8888(
            r: UInt8(totalR / count),
            g: UInt8(totalG / count),
            b: UInt8(totalB / count),
            a: UInt8(totalA / count)
        )
    }
    
    public func squaredDifference(with other: Rgba8888) -> Int64 {
        let dr = Int32(r) - Int32(other.r)
        let dg = Int32(g) - Int32(other.g)
        let db = Int32(b) - Int32(other.b)
        let da = Int32(a) - Int32(other.a)
        return Int64(dr * dr + dg * dg + db * db + da * da)
    }
}

extension Rgba8888: Equatable {}

extension Rgba8888: RGBAccessible {
    // Note: init(r:g:b:) creates color with alpha=255
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(r: r, g: g, b: b, a: 255)
    }
}

extension Rgba8888: AlphaBlendable {
    public var alpha: UInt8 { a }
    
    public func withAlpha(_ alpha: UInt8) -> Rgba8888 {
        Rgba8888(r: r, g: g, b: b, a: alpha)
    }
    
    public func alphaComposite(over background: Rgba8888) -> Rgba8888 {
        // Standard alpha compositing formula
        let srcAlpha = Double(a) / 255.0
        let dstAlpha = Double(background.a) / 255.0
        let outAlpha = srcAlpha + dstAlpha * (1.0 - srcAlpha)
        
        guard outAlpha > 0 else { return .black }
        
        let r = UInt8((Double(r) * srcAlpha + Double(background.r) * dstAlpha * (1.0 - srcAlpha)) / outAlpha)
        let g = UInt8((Double(g) * srcAlpha + Double(background.g) * dstAlpha * (1.0 - srcAlpha)) / outAlpha)
        let b = UInt8((Double(b) * srcAlpha + Double(background.b) * dstAlpha * (1.0 - srcAlpha)) / outAlpha)
        let a = UInt8(outAlpha * 255.0)
        
        return Rgba8888(r: r, g: g, b: b, a: a)
    }
}
