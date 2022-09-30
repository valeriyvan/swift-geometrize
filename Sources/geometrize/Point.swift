import Foundation

public struct Point<N: Numeric> {
    public var x, y: N
    
    public init(x: N, y: N) {
        self.x = x
        self.y = y
    }
}

public extension Point<Int> {
    init(_ p: Point<Double>) {
        x = Int(p.x)
        y = Int(p.y)
    }
}

extension Point: Equatable where N: Equatable {}

extension Point: Hashable where N: Hashable {}

extension Point: CustomStringConvertible where N: CustomStringConvertible {
    public var description: String {
        "Point(x=\(x), y=\(y))"
    }
}
