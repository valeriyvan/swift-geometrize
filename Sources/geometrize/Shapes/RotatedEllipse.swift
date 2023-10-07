import Foundation

// Represents a rotated ellipse.
public final class RotatedEllipse: Shape {
    public var x: Double // x-coordinate.
    public var y: Double // y-coordinate.
    public var rx: Double // x-radius.
    public var ry: Double // y-radius.
    public var angleDegrees: Double // Rotation angle in degrees.

    public required init() {
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
        angleDegrees = 0.0
    }

    public init(x: Double, y: Double, rx: Double, ry: Double, angleDegrees: Double) {
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
        self.angleDegrees = angleDegrees
    }

    public func copy() -> RotatedEllipse {
        RotatedEllipse(x: x, y: y, rx: rx, ry: ry, angleDegrees: angleDegrees)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        x = Double(Int._random(in: xMin...xMax, using: &generator))
        y = Double(Int._random(in: yMin...yMax, using: &generator))
        let range32 = 1...32
        rx = Double(Int._random(in: range32, using: &generator))
        ry = Double(Int._random(in: range32, using: &generator))
        angleDegrees = Double(Int._random(in: 0...360, using: &generator))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let range16 = -16...16
        switch Int._random(in: 0...3, using: &generator) {
        case 0:
            x = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xMin...xMax))
            y = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yMin...yMax))
        case 1:
            rx = Double((Int(rx) + Int._random(in: range16, using: &generator)).clamped(to: 1...xMax))
        case 2:
            ry = Double((Int(ry) + Int._random(in: range16, using: &generator)).clamped(to: 1...yMax))
        case 3:
            angleDegrees = Double((Int(angleDegrees) + Int._random(in: range16, using: &generator)).clamped(to: 0...360))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        guard let polygon = try? Polygon(vertices: points(20).map(Point<Int>.init)) else {
            print("Warning: \(#function) produced no scanlines.")
            return []
        }
        let lines = polygon
            .scanlines()
            .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines.")
        }
        return lines
    }

    private func points(_ count: Int) -> [Point<Double>] {
        var points = [Point<Double>]()
        points.reserveCapacity(count)
        let rads = angleDegrees * (.pi / 180.0)
        let co = cos(rads)
        let si = sin(rads)
        for i in 0..<count {
            let angle = 360.0 / Double(count) * Double(i) * (.pi / 180.0)
            let crx = rx * cos(angle)
            let cry = ry * sin(angle)
            points.append(Point(x: crx * co - cry * si + x, y: crx * si + cry * co + y))
        }
        return points
    }

    public func type() -> ShapeType {
        .rotatedEllipse
    }

    public var isDegenerate: Bool {
        rx == 0.0 || ry == 0.0
    }

    public var description: String {
        "RotatedEllipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry), angleDegrees=\(angleDegrees))"
    }

}
