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
            let difference = diff_(old, new)
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

private func diff<U: UnsignedInteger>(_ l: U, _ r: U) -> U {
    if l > r {
        return l - r
    } else if r > l {
        return r - l
    } else {
        return l
    }
}

private func diff_(_ old: Bitmap, _ new: Bitmap) -> Bitmap {
    if old.isEmpty {
        return new
    } else if new.isEmpty {
        return old
    } else {
        let width = max(old.width, new.width)
        let height = max(old.height, new.height)
        return Bitmap(width: width, height: height) { x, y in
            // https://en.wikipedia.org/wiki/Blend_modes
            // https://imagineer.in/blog/math-behind-blend-modes/
            let o = old.widthIndices ~= x && old.heightIndices ~= y ? old[x, y] : .black
            let n = new.widthIndices ~= x && new.heightIndices ~= y ?  new[x, y] : .black
            return Rgba(r: diff(o.r, n.r), g: diff(o.g, n.g), b: diff(o.b, n.b), a: diff(o.a, n.a))
        }
    }
}
