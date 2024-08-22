import Foundation

public typealias ShapeCreator = @Sendable (inout SplitMix64) -> Shape

/// Creates a function for creating instances of  Shape. Returned instances should be set up!
/// - Parameters:
///   - types: The types of shapes to create.
/// - Returns: The default shape creator.
public func makeDefaultShapeCreator(types: [Shape.Type], strokeWidth: Double) -> ShapeCreator {
    return { generator in
        let index = types.index(
            types.startIndex,
            offsetBy: Int._random(in: 0...types.count - 1, using: &generator)
        )
        let shapeType = types[index]
        return shapeType.init(strokeWidth: strokeWidth)
    }
}
