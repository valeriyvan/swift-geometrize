import Foundation
import Algorithms

struct Polygon<N: SignedInteger> {
    var vertices: [Point<N>]

    init(vertices: [Point<N>]) throws {
        guard vertices.count > 2 else {
            fatalError("Polygon should have more than 2 vertices.")
        }
        // TODO: check if vertices really form a polygon
        self.vertices = vertices
    }

    init(vertices v: (Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2]
    }

    init(vertices v: (Point<N>, Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2, v.3]

    }

    init(vertices v: (Point<N>, Point<N>, Point<N>, Point<N>, Point<N>)) {
        self.vertices = [v.0, v.1, v.2, v.3, v.4]
    }
}

extension Polygon {

    func scanlines() -> [Scanline] {
        var edges = [Point<N>]()
        for i in vertices.indices {
            let p1 = vertices[i]
            let p2 = i == vertices.count - 1 ? vertices[0] : vertices[i + 1]
            let p1p2 = drawThickLine(from: p1, to: p2)
            edges.append(contentsOf: p1p2)
        }
        // Convert outline to scanlines
        var yToXs = [N: Set<N>]()
        for point in edges {
            yToXs[point.y, default: Set()].insert(point.x)
        }
        var lines: [Scanline] = [Scanline]()
        for (y, xs) in yToXs {
            let (xMin, xMax) = xs.minAndMax()! // swiftlint:disable:this force_unwrapping
            let line = Scanline(y: Int(y), x1: Int(xMin), x2: Int(xMax))
            lines.append(line)
        }
        return lines
    }
}
