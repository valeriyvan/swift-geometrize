import Foundation

 // Helper for manipulating RGBA8888 color data.

public struct Rgba {
    
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
        
    public func withAlphaComponent(_ alpha: UInt8) -> Rgba {
        Rgba(r: r, g: g, b: b, a: alpha)
    }
    
    public static var black: Rgba { Rgba(r: 0, g: 0, b: 0, a: 255) }
    public static var white: Rgba { Rgba(r: 255, g: 255, b: 255, a: 255) }
    public static var red: Rgba { Rgba(r: 255, g: 0, b: 0, a: 255) }
    public static var green: Rgba { Rgba(r: 0, g: 255, b: 0, a: 255) }
    public static var blue: Rgba { Rgba(r: 0, g: 0, b: 255, a: 255) }
    public static var yellow: Rgba { Rgba(r: 255, g: 255, b: 0, a: 255) }

}

extension Rgba: Equatable {}
