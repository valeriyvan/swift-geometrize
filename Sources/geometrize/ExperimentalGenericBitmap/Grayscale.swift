import Foundation

/// Helper for manipulating grayscale color data.
/// Grayscale uses 1 byte per pixel for luminance values (0-255).
@frozen
public struct Grayscale: Color {
    
    /// Luminance value (0-255, where 0 is black and 255 is white)
    public var luminance: UInt8
    
    /// Initialize from luminance value
    public init(luminance: UInt8) {
        self.luminance = luminance
    }
    
    /// Initialize from RGB values using standard luminance formula
    /// Uses ITU-R BT.709 luma coefficients: Y = 0.2126*R + 0.7152*G + 0.0722*B
    public init(r: UInt8, g: UInt8, b: UInt8) {
        let luma = 0.2126 * Double(r) + 0.7152 * Double(g) + 0.0722 * Double(b)
        self.luminance = UInt8(luma.rounded())
    }
    
    /// Convert to RGB components (all channels have the same value)
    public var r: UInt8 { luminance }
    public var g: UInt8 { luminance }
    public var b: UInt8 { luminance }
    
    /// Convert to single-element array
    public var asArray: [UInt8] { [luminance] }
    
    /// Convert to RGB array (duplicates luminance to R, G, B)
    public var asRgbArray: [UInt8] { [luminance, luminance, luminance] }
    
    /// Convert to RGBA array (duplicates luminance to R, G, B, alpha = 255)
    public var asRgbaArray: [UInt8] { [luminance, luminance, luminance, 255] }
}

// MARK: - Color Protocol Conformance

extension Grayscale {
    public static let componentCount = 1
    public static let componentSize = 1
    public static let totalSize = 1
    
    public init(from buffer: UnsafeBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        self.luminance = buffer[offset]
    }
    
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        buffer[offset] = luminance
    }
    
    public static var black: Grayscale { Grayscale(luminance: 0) }
    public static var white: Grayscale { Grayscale(luminance: 255) }
    
    // Standard grayscale values for common colors
    public static var darkGray: Grayscale { Grayscale(luminance: 64) }
    public static var gray: Grayscale { Grayscale(luminance: 128) }
    public static var lightGray: Grayscale { Grayscale(luminance: 192) }
    
    // Color equivalents using luminance formula
    public static var red: Grayscale { Grayscale(r: 255, g: 0, b: 0) }     // ~54
    public static var green: Grayscale { Grayscale(r: 0, g: 255, b: 0) }   // ~182
    public static var blue: Grayscale { Grayscale(r: 0, g: 0, b: 255) }    // ~18
    public static var yellow: Grayscale { Grayscale(r: 255, g: 255, b: 0) } // ~237
    public static var magenta: Grayscale { Grayscale(r: 255, g: 0, b: 255) } // ~73
    public static var cyan: Grayscale { Grayscale(r: 0, g: 255, b: 255) } // ~201

    /// Blends this grayscale value with a background.
    /// Since grayscale has no alpha channel, this simply returns self.
    public func blending(background: Grayscale) -> Grayscale {
        // Grayscale has no alpha channel, so no blending is needed
        return self
    }
    
    public static func average(of colors: [Grayscale]) -> Grayscale {
        guard !colors.isEmpty else { return .black }
        
        let count = UInt64(colors.count)
        var total: UInt64 = 0
        
        for color in colors {
            total += UInt64(color.luminance)
        }
        
        return Grayscale(luminance: UInt8(total / count))
    }

    public func squaredDifference(with other: Grayscale) -> Int64 {
        let dl = Int32(luminance) - Int32(other.luminance)
        return Int64(dl * dl)
    }

}

// MARK: - Conversion Extensions

extension Grayscale {
    /// Convert to RGBA8888
    public func toRgba8888() -> Rgba8888 {
        Rgba8888(r: luminance, g: luminance, b: luminance, a: 255)
    }
    
    /// Convert to RGB565 (all channels get the same value)
    public func toRgb565() -> Rgb565 {
        Rgb565(r: luminance, g: luminance, b: luminance)
    }
}

extension Rgba8888 {
    /// Convert to grayscale using luminance formula
    public func toGrayscale() -> Grayscale {
        Grayscale(r: r, g: g, b: b)
    }
}

extension Rgb565 {
    /// Convert to grayscale using luminance formula
    public func toGrayscale() -> Grayscale {
        Grayscale(r: r, g: g, b: b)
    }
}

extension Grayscale: RGBAccessible {
    // Already implements init(r:g:b:) in the main struct
}

extension Grayscale: Equatable {}
