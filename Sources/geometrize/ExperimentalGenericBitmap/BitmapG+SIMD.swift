import Foundation

// SIMD optimizations for Rgba8888
extension BitmapG where ColorType == Rgba8888 {
    
    // buffer.baseAddress! must be 4-bytes aligned and offset must be a multiple of 4.
    // ContiguousArray<UInt8> de-facto guarantees this providing 16 bytes alignment on 64-bits
    // and 8 bytes - on 32-bits.
    // That detail comes from Swift's runtime memory allocation strategy and is not documented
    // in the Swift standard library, but is inferred from runtime behavior
    @inlinable
    @inline(__always)
    internal func rgbaAsSIMD4Int32(x: Int, y: Int) -> SIMD4<Int32> {
        backing.withUnsafeBufferPointer { buffer in
            let offset = offset(x: x, y: y)
            let small: SIMD4<UInt8> = buffer.baseAddress! // UnsafePointer<UInt8>
                .advanced(by: offset)
                .withMemoryRebound(to: SIMD4<UInt8>.self, capacity: 1) {
                    $0.pointee
                }
            return SIMD4<Int32>(truncatingIfNeeded: small)
        }
    }
    
    /// Optimized average color computation using SIMD operations.
    /// Provides ~8% performance boost on M1 compared to non-SIMD version.
    public func averageColorSIMD() -> Rgba8888 {
        guard !isEmpty else { return .black }

        // SIMD version gives ~8% performance boost on M1
        var total: SIMD4<UInt64> = .zero
        backing.withUnsafeBufferPointer { buffer in
            for i in 0 ..< self.pixelCount {
                let small: SIMD4<UInt8> = buffer.baseAddress! // UnsafePointer<UInt8>
                    .advanced(by: i * 4)
                    .withMemoryRebound(to: SIMD4<UInt8>.self, capacity: 1) {
                        $0.pointee
                    }
                let rgba = SIMD4<UInt64>(truncatingIfNeeded: small)
                total &+= rgba
            }
        }

        let pixelCount = UInt64(self.pixelCount)
        total /= pixelCount
        return Rgba8888(
            r: UInt8(total.x),
            g: UInt8(total.y),
            b: UInt8(total.z),
            a: 255 // TODO: calculate average of alpha?
        )
    }
    
    /// SIMD-optimized fill operation for RGBA8888
    public mutating func fillSIMD(color: Rgba8888) {
        let packedColor = UInt32(color.r) | (UInt32(color.g) << 8) | (UInt32(color.b) << 16) | (UInt32(color.a) << 24)
        let count = pixelCount  // Capture outside the closure
        
        backing.withUnsafeMutableBufferPointer { buffer in
            buffer.withMemoryRebound(to: UInt32.self) { uint32Buffer in
                for i in 0..<count {
                    uint32Buffer[i] = packedColor
                }
            }
        }
    }
    
    /// SIMD-optimized bitmap blending for RGBA8888
    public func blendSIMD(with other: BitmapG<Rgba8888>, alpha: Float = 0.5) -> BitmapG<Rgba8888> {
        assert(width == other.width && height == other.height, "Bitmap dimensions must match")
        
        var result = BitmapG<Rgba8888>(width: width, height: height, color: .black)
        
        for y in 0..<height {
            for x in 0..<width {
                let color1 = self.rgbaAsSIMD4Int32(x: x, y: y)
                let color2 = other.rgbaAsSIMD4Int32(x: x, y: y)
                
                let alpha32 = SIMD4<Int32>(repeating: Int32(alpha * 256)) // Fixed-point alpha
                let invAlpha32 = SIMD4<Int32>(repeating: 256) &- alpha32
                
                let blended = (color1 &* alpha32 &+ color2 &* invAlpha32) &>> 8
                
                result[x, y] = Rgba8888(
                    r: UInt8(max(0, min(255, blended.x))),
                    g: UInt8(max(0, min(255, blended.y))),
                    b: UInt8(max(0, min(255, blended.z))),
                    a: UInt8(max(0, min(255, blended.w)))
                )
            }
        }
        
        return result
    }
}

// SIMD optimizations for other color formats can be added here
extension BitmapG where ColorType == Rgb565 {
    /// SIMD-optimized operations for RGB565 could process multiple pixels at once
    /// using 16-bit operations, but the current generic implementation is already quite efficient
    /// for this format due to its compact size.
}

extension BitmapG where ColorType == Grayscale {
    /// SIMD-optimized operations for Grayscale could process 16 pixels at once
    /// using SIMD16<UInt8>, providing significant performance improvements for
    /// large grayscale images.
    public mutating func fillSIMD(luminance: UInt8) {
        let simdValue = SIMD16<UInt8>(repeating: luminance)
        
        backing.withUnsafeMutableBufferPointer { buffer in
            let simdCount = buffer.count / 16
            buffer.withMemoryRebound(to: SIMD16<UInt8>.self) { simdBuffer in
                for i in 0..<simdCount {
                    simdBuffer[i] = simdValue
                }
            }
            
            // Handle remaining bytes
            let remainder = buffer.count % 16
            if remainder > 0 {
                let startIndex = simdCount * 16
                for i in 0..<remainder {
                    buffer[startIndex + i] = luminance
                }
            }
        }
    }
}

extension BitmapG where ColorType == Binary {
    /// SIMD-optimized operations for Binary could process 128 pixels at once
    /// using bit manipulation on SIMD16<UInt8>, but this would require
    /// a more complex packed storage format.
}