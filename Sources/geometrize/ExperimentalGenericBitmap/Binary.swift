import Foundation

/// Helper for manipulating binary (1-bit) color data.
/// Binary uses 1 bit per pixel, stored as 1 byte per pixel for simplicity.
/// True values represent white/foreground, false values represent black/background.
@frozen
public struct Binary: Color {
    
    /// Binary value (true = white/foreground, false = black/background)
    public var value: Bool
    
    /// Initialize from boolean value
    public init(value: Bool) {
        self.value = value
    }
    
    /// Initialize from luminance threshold (>=128 becomes true/white, <128 becomes false/black)
    public init(luminance: UInt8, threshold: UInt8 = 128) {
        self.value = luminance >= threshold
    }
    
    /// Initialize from RGB values using luminance and threshold
    /// Uses ITU-R BT.709 luma coefficients with default threshold of 128
    public init(r: UInt8, g: UInt8, b: UInt8, threshold: UInt8 = 128) {
        let luma = 0.2126 * Double(r) + 0.7152 * Double(g) + 0.0722 * Double(b)
        self.value = UInt8(luma.rounded()) >= threshold
    }
    
    /// Convert to luminance value (0 for false/black, 255 for true/white)
    public var luminance: UInt8 { value ? 255 : 0 }
    
    /// Convert to RGB components (all channels have the same value)
    public var r: UInt8 { luminance }
    public var g: UInt8 { luminance }
    public var b: UInt8 { luminance }
    
    /// Convert to single-element boolean array
    public var asBoolArray: [Bool] { [value] }
    
    /// Convert to single-element byte array (0 or 255)
    public var asArray: [UInt8] { [luminance] }
    
    /// Convert to RGB array
    public var asRgbArray: [UInt8] { [luminance, luminance, luminance] }
    
    /// Convert to RGBA array (alpha = 255)
    public var asRgbaArray: [UInt8] { [luminance, luminance, luminance, 255] }
    
    /// Logical NOT operation
    public var inverted: Binary { Binary(value: !value) }
}

// MARK: - Color Protocol Conformance

extension Binary {
    public static let componentCount = 1
    public static let componentSize = 1  // Store as 1 byte for simplicity (could be optimized to pack 8 pixels per byte)
    public static let totalSize = 1
    
    public init(from buffer: UnsafeBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        // Store as 0 or 255, any non-zero value is considered true
        self.value = buffer[offset] != 0
    }
    
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at offset: Int) {
        assert(buffer.count >= offset + Self.totalSize)
        buffer[offset] = value ? 255 : 0
    }
    
    public static var black: Binary { Binary(value: false) }
    public static var white: Binary { Binary(value: true) }
    
    // For binary images, most colors map to either black or white based on luminance
    public static var red: Binary { Binary(r: 255, g: 0, b: 0) }       // false (dark)
    public static var green: Binary { Binary(r: 0, g: 255, b: 0) }     // true (bright)
    public static var blue: Binary { Binary(r: 0, g: 0, b: 255) }      // false (dark)
    public static var yellow: Binary { Binary(r: 255, g: 255, b: 0) }  // true (bright)
    public static var magenta: Binary { Binary(r: 255, g: 0, b: 255) } // false (medium, below threshold)
    public static var cyan: Binary { Binary(r: 0, g: 255, b: 255) }    // true (bright)

    /// Blends this binary value with a background using logical OR.
    /// This creates a union effect where any foreground pixel remains foreground.
    public func blending(background: Binary) -> Binary {
        // For binary images, blending could be OR, AND, XOR, etc.
        // Using OR as default: foreground (true) pixels always win
        Binary(value: self.value || background.value)
    }
    
    public static func average(of colors: [Binary]) -> Binary {
        guard !colors.isEmpty else { return .black }
        
        let trueCount = colors.reduce(0) { $0 + ($1.value ? 1 : 0) }
        let ratio = Double(trueCount) / Double(colors.count)
        
        // Use majority voting: if more than half are true, result is true
        return Binary(value: ratio >= 0.5)
    }
    
    public func squaredDifference(with other: Binary) -> Int64 {
        // For binary values, difference is either 0 (same) or 255 (different)
        let diff = Int32(luminance) - Int32(other.luminance)
        return Int64(diff * diff)
    }
}

// MARK: - Binary Operations

extension Binary {
    /// Logical AND operation
    public static func & (lhs: Binary, rhs: Binary) -> Binary {
        Binary(value: lhs.value && rhs.value)
    }
    
    /// Logical OR operation
    public static func | (lhs: Binary, rhs: Binary) -> Binary {
        Binary(value: lhs.value || rhs.value)
    }
    
    /// Logical XOR operation
    public static func ^ (lhs: Binary, rhs: Binary) -> Binary {
        Binary(value: lhs.value != rhs.value)
    }
    
    /// Logical NOT operation (prefix)
    public static prefix func ! (operand: Binary) -> Binary {
        operand.inverted
    }
}

// MARK: - Conversion Extensions

extension Binary {
    /// Convert to RGBA8888
    public func toRgba8888() -> Rgba8888 {
        let lum = luminance
        return Rgba8888(r: lum, g: lum, b: lum, a: 255)
    }
    
    /// Convert to RGB565
    public func toRgb565() -> Rgb565 {
        let lum = luminance
        return Rgb565(r: lum, g: lum, b: lum)
    }
    
    /// Convert to Grayscale
    public func toGrayscale() -> Grayscale {
        Grayscale(luminance: luminance)
    }
}

extension Rgba8888 {
    /// Convert to binary using luminance threshold
    public func toBinary(threshold: UInt8 = 128) -> Binary {
        Binary(r: r, g: g, b: b, threshold: threshold)
    }
}

extension Rgb565 {
    /// Convert to binary using luminance threshold
    public func toBinary(threshold: UInt8 = 128) -> Binary {
        Binary(r: r, g: g, b: b, threshold: threshold)
    }
}

extension Grayscale {
    /// Convert to binary using luminance threshold
    public func toBinary(threshold: UInt8 = 128) -> Binary {
        Binary(luminance: luminance, threshold: threshold)
    }
}

// MARK: - Bitmap Extensions for Binary Operations

extension BitmapG where ColorType == Binary {
    /// Apply logical AND operation with another binary bitmap
    public func and(with other: BitmapG<Binary>) -> BitmapG<Binary> {
        assert(width == other.width && height == other.height, "Bitmap dimensions must match")
        return BitmapG(width: width, height: height) { x, y in
            self[x, y] & other[x, y]
        }
    }
    
    /// Apply logical OR operation with another binary bitmap
    public func or(with other: BitmapG<Binary>) -> BitmapG<Binary> {
        assert(width == other.width && height == other.height, "Bitmap dimensions must match")
        return BitmapG(width: width, height: height) { x, y in
            self[x, y] | other[x, y]
        }
    }
    
    /// Apply logical XOR operation with another binary bitmap
    public func xor(with other: BitmapG<Binary>) -> BitmapG<Binary> {
        assert(width == other.width && height == other.height, "Bitmap dimensions must match")
        return BitmapG(width: width, height: height) { x, y in
            self[x, y] ^ other[x, y]
        }
    }
    
    /// Invert all pixels (logical NOT)
    public func inverted() -> BitmapG<Binary> {
        return BitmapG(width: width, height: height) { x, y in
            !self[x, y]
        }
    }
    
    /// Count the number of foreground (true/white) pixels
    public func foregroundPixelCount() -> Int {
        var count = 0
        for y in 0..<height {
            for x in 0..<width {
                if self[x, y].value {
                    count += 1
                }
            }
        }
        return count
    }
    
    /// Get the ratio of foreground pixels (0.0 to 1.0)
    public func foregroundRatio() -> Double {
        guard pixelCount > 0 else { return 0.0 }
        return Double(foregroundPixelCount()) / Double(pixelCount)
    }
}

extension Binary: RGBAccessible {
    public init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(r: r, g: g, b: b, threshold: 128)
    }
}

extension Binary: Equatable {}