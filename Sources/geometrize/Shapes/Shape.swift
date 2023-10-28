import Foundation

public protocol Shape: AnyObject, CustomStringConvertible {
    var strokeWidth: Double { get }

    init(strokeWidth: Double)

    func copy() -> Self

    func setup(x: ClosedRange<Int>, y: ClosedRange<Int>, using: inout SplitMix64)

    func mutate(x: ClosedRange<Int>, y: ClosedRange<Int>, using: inout SplitMix64)

    func rasterize(x: ClosedRange<Int>, y: ClosedRange<Int>) -> [Scanline]

    var isDegenerate: Bool { get }
}

extension Shape {

    public var isDegenerate: Bool {
        false
    }

}

func == (lhs: any Shape, rhs: any Shape) -> Bool {
    switch (lhs, rhs) {
    case (let lhs as Rectangle, let rhs as Rectangle): return lhs == rhs
    default: return false
    }
}
