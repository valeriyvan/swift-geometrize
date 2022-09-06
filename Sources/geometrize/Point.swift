import Foundation

struct Point<SignedInteger> {
    var x, y: SignedInteger
}

extension Point<Int> {
    init(_ p: Point<Double>) {
        x = Int(p.x)
        y = Int(p.y)
    }
}
