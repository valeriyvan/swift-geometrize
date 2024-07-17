import Foundation

public protocol Mutable {

    func setup(x: ClosedRange<Int>, y: ClosedRange<Int>, using: inout SplitMix64) -> Self

    func mutate(x: ClosedRange<Int>, y: ClosedRange<Int>, using: inout SplitMix64) -> Self

}

public protocol Rasterizable {

    var strokeWidth: Double { get }

    init(strokeWidth: Double)

    func rasterize(x: ClosedRange<Int>, y: ClosedRange<Int>) -> [Scanline]

}

public protocol Shape: Sendable, Mutable, Rasterizable, CustomStringConvertible {

    var isDegenerate: Bool { get }

}

extension Shape {

    public var isDegenerate: Bool {
        false
    }

}
