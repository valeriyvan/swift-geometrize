import XCTest
@preconcurrency import SnapshotTesting
import PNG
@testable import Geometrize
import BitmapImportExport

// Generic diffing support for BitmapG
extension Diffing where Value == BitmapG<Rgba8888> {

    /// A pixel-diffing strategy for BitmapG<Rgba8888> which requires a 100% match.
    public static let image = Diffing.image(precision: 1.0)

    /// A pixel-diffing strategy for BitmapG<Rgba8888> that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Returns: A new diffing strategy.
    public static func image(precision: Double) -> Diffing {
        Diffing(
            toData: { try! $0.pngData() }, // swiftlint:disable:this force_try
            fromData: { try! .init(pngData: $0) } // swiftlint:disable:this force_try
        ) { old, new -> (String, [XCTAttachment])? in // swiftlint:disable:this multiple_closures_with_trailing_closure
            guard !old.compare(with: new, precision: precision) else { return nil }
            let difference = old.diff(with: new)
            let message = new.width == old.width && new.height == old.height
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.width),\(new.height) does not match reference@\(old.width),\(old.height)."
            let oldAttachment = XCTAttachment(
                data: try! old.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            // oldAttachment.name = "reference"
            // on Ubuntu this produces error
            // error: value of type 'XCTAttachment' has no member 'name'
            let newAttachment = XCTAttachment(
                data: try! new.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            // newAttachment.name = "failure"
            let differenceAttachment = XCTAttachment(
                data: try! difference.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            // differenceAttachment.name = "difference"
            return (
                message,
                [oldAttachment, newAttachment, differenceAttachment]
            )
        }
    }

}

// Generic diffing support for any RGB-accessible color format
extension Diffing {
    
    /// A pixel-diffing strategy for BitmapG with any RGB-accessible color format.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Returns: A new diffing strategy.
    public static func image<ColorType: RGBAccessible>(precision: Double) -> Diffing<BitmapG<ColorType>> {
        Diffing<BitmapG<ColorType>>(
            toData: { bitmap in
                // Convert to RGBA8888 for PNG export
                let rgba8888Bitmap = BitmapG<Rgba8888>(width: bitmap.width, height: bitmap.height) { x, y in
                    let color = bitmap[x, y]
                    return Rgba8888(r: color.r, g: color.g, b: color.b, a: 255)
                }
                return try! rgba8888Bitmap.pngData() // swiftlint:disable:this force_try
            },
            fromData: { data in
                // Import as RGBA8888 then convert to target format
                let rgba8888Bitmap = try! BitmapG<Rgba8888>(pngData: data) // swiftlint:disable:this force_try
                return BitmapG<ColorType>(width: rgba8888Bitmap.width, height: rgba8888Bitmap.height) { x, y in
                    let rgba = rgba8888Bitmap[x, y]
                    return ColorType(r: rgba.r, g: rgba.g, b: rgba.b)
                }
            }
        ) { old, new -> (String, [XCTAttachment])? in
            guard !old.compare(with: new, precision: precision) else { return nil }
            let difference = old.diff(with: new)
            let message = new.width == old.width && new.height == old.height
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.width),\(new.height) does not match reference@\(old.width),\(old.height)."
            
            // Convert all to RGBA8888 for PNG export in attachments
            let oldRgba = BitmapG<Rgba8888>(width: old.width, height: old.height) { x, y in
                let color = old[x, y]
                return Rgba8888(r: color.r, g: color.g, b: color.b, a: 255)
            }
            let newRgba = BitmapG<Rgba8888>(width: new.width, height: new.height) { x, y in
                let color = new[x, y]
                return Rgba8888(r: color.r, g: color.g, b: color.b, a: 255)
            }
            let diffRgba = BitmapG<Rgba8888>(width: difference.width, height: difference.height) { x, y in
                let color = difference[x, y]
                return Rgba8888(r: color.r, g: color.g, b: color.b, a: 255)
            }
            
            let oldAttachment = XCTAttachment(
                data: try! oldRgba.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            let newAttachment = XCTAttachment(
                data: try! newRgba.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            let differenceAttachment = XCTAttachment(
                data: try! diffRgba.pngData(), // swiftlint:disable:this force_try
                uniformTypeIdentifier: "public.png"
            )
            
            return (
                message,
                [oldAttachment, newAttachment, differenceAttachment]
            )
        }
    }
}

// Diffing like compare from imagemagick when difference is highlighted in red and
// original image is dimmed (drawn with 10% of its alpha).
fileprivate extension BitmapG where ColorType: RGBAccessible {

    func diff(with other: BitmapG<ColorType>) -> BitmapG<ColorType> {
        if isEmpty {
            return other
        } else if other.isEmpty {
            return self
        } else {
            let width = max(width, other.width)
            let height = max(height, other.height)
            return BitmapG<ColorType>(width: width, height: height) { x, y in
                // https://en.wikipedia.org/wiki/Blend_modes
                // https://imagineer.in/blog/math-behind-blend-modes/
                let o = widthIndices ~= x && heightIndices ~= y ? self[x, y] : ColorType.white
                let n = other.widthIndices ~= x && other.heightIndices ~= y ? other[x, y] : ColorType.white
                return o.diff(with: n)
            }
        }
    }

}

// Generic color diffing for RGB-accessible colors
fileprivate extension RGBAccessible {

    func diff(with other: Self) -> Self {
        guard self != other else {
            // Dim the original image (reduce intensity by 90%)
            return Self(r: r / 10, g: g / 10, b: b / 10)
        }
        // Highlight differences in red
        return Self(r: 255, g: 0, b: 0)
    }

}

// Specialized implementations for formats that support alpha
fileprivate extension Rgba8888 {
    
    func diff(with other: Rgba8888) -> Rgba8888 {
        guard self != other else {
            return withAlpha(a / 10)  // Use existing withAlpha method
        }
        return .red
    }
    
}