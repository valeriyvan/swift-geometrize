import Foundation

/// Protocol defining the interface for color formats used in generic Bitmap.
public protocol Color: Sendable, Equatable {
    /// Number of color components (e.g., 4 for RGBA, 3 for RGB)
    static var componentCount: Int { get }
    
    /// Size in bytes per component
    static var componentSize: Int { get }
    
    /// Total size in bytes per pixel
    static var totalSize: Int { get }
    
    /// Creates a color instance from raw byte data at the specified offset
    /// - Parameters:
    ///   - buffer: Buffer containing the raw color data
    ///   - offset: Byte offset in the buffer where this color starts
    init(from buffer: UnsafeBufferPointer<UInt8>, at offset: Int)
    
    /// Writes the color data to a buffer at the specified offset
    /// - Parameters:
    ///   - buffer: Mutable buffer to write the color data to
    ///   - offset: Byte offset in the buffer where to write this color
    func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at offset: Int)
    
    /// Standard black color for this format
    static var black: Self { get }
    
    /// Standard white color for this format
    static var white: Self { get }
    
    /// Blends this color with a background color, returning an opaque result
    /// - Parameter background: The background color to blend with
    /// - Returns: The blended color (typically with full opacity)
    func blending(background: Self) -> Self
    
    /// Creates an average color from an array of colors
    /// - Parameter colors: Array of colors to average
    /// - Returns: The average color
    static func average(of colors: [Self]) -> Self
    
    /// Calculates the squared difference between this color and another color
    /// Used for computing bitmap differences in geometrization algorithms
    /// - Parameter other: The other color to compare with
    /// - Returns: The sum of squared differences for all color components
    func squaredDifference(with other: Self) -> Int64
}

/// Protocol for colors that support alpha blending operations
public protocol AlphaBlendable: Color {
    /// Alpha component accessor (0-255 range)
    var alpha: UInt8 { get }
    
    /// Creates a new color with the specified alpha value
    func withAlpha(_ alpha: UInt8) -> Self
    
    /// Performs alpha compositing with another color
    /// - Parameter background: Background color to composite over
    /// - Returns: Composited color result
    func alphaComposite(over background: Self) -> Self
}

/// Protocol for colors that provide RGB component access
public protocol RGBAccessible: Color {
    /// Red component (0-255)
    var r: UInt8 { get }
    
    /// Green component (0-255)
    var g: UInt8 { get }
    
    /// Blue component (0-255)
    var b: UInt8 { get }
    
    /// Create color from RGB components
    init(r: UInt8, g: UInt8, b: UInt8)
}