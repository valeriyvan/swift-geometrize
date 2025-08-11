import Foundation

/// Helper for manipulating RGB565 color data.
/// RGB565 packs 16-bit color into 2 bytes: 5 bits red, 6 bits green, 5 bits blue.
@frozen
public struct Rgb565: Color {
    
    /// Packed 16-bit value containing RGB data
    public var packed: UInt16
    
    /// Red component (0-255), extracted from 5-bit value
    public var r: UInt8 {
        get {
            let fiveBit = UInt8((packed >> 11) & 0x1F)
            // Scale 5-bit (0-31) to 8-bit (0-255)
            return (fiveBit << 3) | (fiveBit >> 2)
        }
        set {
            // Scale 8-bit (0-255) to 5-bit (0-31)
            let fiveBit = UInt16(newValue >> 3)
            packed = (packed & 0x07FF) | (fiveBit << 11)
        }
    }
    
    /// Green component (0-255), extracted from 6-bit value
    public var g: UInt8 {
        get {
            let sixBit = UInt8((packed >> 5) & 0x3F)
            // Scale 6-bit (0-63) to 8-bit (0-255)
            return (sixBit << 2) | (sixBit >> 4)
        }
        set {
            // Scale 8-bit (0-255) to 6-bit (0-63)
            let sixBit = UInt16(newValue >> 2)
            packed = (packed & 0xF81F) | (sixBit << 5)
        }
    }
    
    /// Blue component (0-255), extracted from 5-bit value
    public var b: UInt8 {
        get {
            let fiveBit = UInt8(packed & 0x1F)
            // Scale 5-bit (0-31) to 8-bit (0-255)
            return (fiveBit << 3) | (fiveBit >> 2)
        }
        set {
            // Scale 8-bit (0-255) to 5-bit (0-31)
            let fiveBit = UInt16(newValue >> 3)
            packed = (packed & 0xFFE0) | fiveBit
        }
    }

    /// Initialize from RGB components
    public init(r: UInt8, g: UInt8, b: UInt8) {
        let r5 = UInt16(r >> 3)
        let g6 = UInt16(g >> 2)
        let b5 = UInt16(b >> 3)
        self.packed = (r5 << 11) | (g6 << 5) | b5
    }
    
    /// Initialize from packed 16-bit value
    public init(packed: UInt16) {
        self.packed = packed
    }
    
    /// Convert to 8-bit RGB array (no alpha)
    public var asRgbArray: [UInt8] { [r, g, b] }
    
    /// Convert to 8-bit RGBA array (alpha set to 255)
    public var asRgbaArray: [UInt8] { [r, g, b, 255] }
}

// MARK: - Color Protocol Conformance

extension Rgb565 {
    public static let componentCount = 3
    public static let componentSize = 2  // packed into 2 bytes total
    public static let totalSize = 2
    
    public init(from buffer: UnsafeBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        // Read as little-endian 16-bit value
        let low = UInt16(buffer[offset])
        let high = UInt16(buffer[offset + 1])
        self.packed = low | (high << 8)
    }
    
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        // Write as little-endian 16-bit value
        buffer[offset] = UInt8(packed & 0xFF)
        buffer[offset + 1] = UInt8(packed >> 8)
    }
    
    public static var black: Rgb565 { Rgb565(r: 0, g: 0, b: 0) }
    public static var white: Rgb565 { Rgb565(r: 255, g: 255, b: 255) }
    public static var red: Rgb565 { Rgb565(r: 255, g: 0, b: 0) }
    public static var green: Rgb565 { Rgb565(r: 0, g: 255, b: 0) }
    public static var blue: Rgb565 { Rgb565(r: 0, g: 0, b: 255) }
    public static var yellow: Rgb565 { Rgb565(r: 255, g: 255, b: 0) }
    public static var magenta: Rgb565 { Rgb565(r: 255, g: 0, b: 255) }
    public static var cyan: Rgb565 { Rgb565(r: 0, g: 255, b: 255) }

    /// Blends this color with a background color.
    /// Since RGB565 has no alpha channel, this simply returns self.
    public func blending(background: Rgb565) -> Rgb565 {
        // RGB565 has no alpha channel, so no blending is needed
        return self
    }
    
    public static func average(of colors: [Rgb565]) -> Rgb565 {
        guard !colors.isEmpty else { return .black }
        
        let count = UInt64(colors.count)
        var totalR: UInt64 = 0
        var totalG: UInt64 = 0
        var totalB: UInt64 = 0
        
        for color in colors {
            totalR += UInt64(color.r)
            totalG += UInt64(color.g)
            totalB += UInt64(color.b)
        }
        
        return Rgb565(
            r: UInt8(totalR / count),
            g: UInt8(totalG / count),
            b: UInt8(totalB / count)
        )
    }
    
    public func squaredDifference(with other: Rgb565) -> Int64 {
        let dr = Int32(r) - Int32(other.r)
        let dg = Int32(g) - Int32(other.g)
        let db = Int32(b) - Int32(other.b)
        return Int64(dr * dr + dg * dg + db * db)
    }
}

extension Rgb565: RGBAccessible {
    // Already implements init(r:g:b:) in the main struct
}

extension Rgb565: Equatable {}