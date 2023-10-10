import Foundation

public protocol Shape: AnyObject, CustomStringConvertible {
    init()

    func copy() -> Self

    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using: inout SplitMix64)

    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using: inout SplitMix64)

    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline]

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

public let allShapeTypes: [Shape.Type] = [
    Rectangle.self,
    RotatedRectangle.self,
    Triangle.self,
    Circle.self,
    Ellipse.self,
    RotatedEllipse.self,
    Line.self,
    Polyline.self,
    QuadraticBezier.self
]

public extension Array where Element == String {

    func shapeTypes() -> [Shape.Type?] {
        let allShapeTypeStrings = allShapeTypes.map { "\(type(of: $0))".dropLast(5).lowercased() } // /* drop .Type */
        return self.map {
            let needle = $0.lowercased().replacingOccurrences(of: "_", with: "")
            return allShapeTypeStrings.firstIndex(of: needle).flatMap { allShapeTypes[$0] }
        }
    }

}
