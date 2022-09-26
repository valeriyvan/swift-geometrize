import XCTest
import SnapshotTesting
import PNG
@testable import geometrize

extension XCTAttachment {
    convenience init(bitmap: Bitmap) {
        self.init(data: try! bitmap.pngData(), uniformTypeIdentifier: "public.png")
    }
}

extension Diffing where Value == Bitmap {
    
    /// A pixel-diffing strategy for UIImage's which requires a 100% match.
    public static let image = Diffing.image(precision: 1.0)
    
    /// A pixel-diffing strategy for UIImage that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Returns: A new diffing strategy.
    public static func image(precision: Double) -> Diffing {
        Diffing(
            toData: { try! $0.pngData() },
            fromData: { try! .init(pngData: $0) }
        ) { old, new -> (String, [XCTAttachment])? in
            guard !old.compare(with: new, precision: precision) else { return nil }
            let difference = old.diff(with: new)
            let message = new.width == old.width && new.height == old.height
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.width),\(new.height) does not match reference@\(old.width),\(old.height)."
            let oldAttachment = XCTAttachment(bitmap: old)
            oldAttachment.name = "reference"
            let newAttachment = XCTAttachment(bitmap: new)
            newAttachment.name = "failure"
            let differenceAttachment = XCTAttachment(bitmap: difference)
            differenceAttachment.name = "difference"
            return (
                message,
                [oldAttachment, newAttachment, differenceAttachment]
            )
        }
    }
    
}

// Diffing like compare from imagemagick when difference is highlighted in red and
// original image is dimmed (drawn with 10% of its alpha).
fileprivate extension Bitmap {
    
    func diff(with other: Bitmap) -> Bitmap {
        if isEmpty {
            return other
        } else if other.isEmpty {
            return self
        } else {
            let width = max(width, other.width)
            let height = max(height, other.height)
            return Bitmap(width: width, height: height) { x, y in
                // https://en.wikipedia.org/wiki/Blend_modes
                // https://imagineer.in/blog/math-behind-blend-modes/
                let o = widthIndices ~= x && heightIndices ~= y ? self[x, y] : .white
                let n = other.widthIndices ~= x && other.heightIndices ~= y ?  other[x, y] : .white
                return o.diff(with: n)
            }
        }
    }
    
}

fileprivate extension Rgba {
    
    func diff(with other: Rgba) -> Rgba {
        guard self != other else {
            return withAlphaComponent(a / 10)
        }
        return .red
    }
    
}
