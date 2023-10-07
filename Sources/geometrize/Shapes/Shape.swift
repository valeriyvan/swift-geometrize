import Foundation

// Specifies the types of shapes that can be used.
// These can be combined to produce images composed of multiple primitive types.
// TODO: put it inside Shape. Or remove completely.
public enum ShapeType: String, CaseIterable {
    case rectangle
    case rotatedRectangle
    case triangle
    case ellipse
    case rotatedEllipse
    case circle
    case line
    case quadraticBezier
    case polyline

    public var rawValueCapitalized: String {
        let firstUppercased = rawValue.first!.uppercased()
        return firstUppercased + rawValue.dropFirst()
    }

    // Allows rotatedrectangle and rotated_rectangle, casing doesn't matter.
    public init?(rawValue: String) {
        let allCases = ShapeType.allCases
        let all = allCases.map { $0.rawValue.lowercased() }
        guard let index = all.firstIndex(of: rawValue.replacingOccurrences(of: "_", with: "").lowercased()) else {
            return nil
        }
        self = allCases[index]
    }
}

public struct Bounds {
    let xMin: Int
    let xMax: Int
    let yMin: Int
    let yMax: Int

    public init(xMin: Int, xMax: Int, yMin: Int, yMax: Int) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }
}

public protocol Shape: AnyObject, CustomStringConvertible {
    init()

    func copy() -> Self

    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using: inout SplitMix64)

    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using: inout SplitMix64)

    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline]

    func type() -> ShapeType

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
