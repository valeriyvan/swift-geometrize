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

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x = Double(randomRange(min: xMin, max: xMax - 1))
        y = Double(randomRange(min: yMin, max: yMax - 1))
        rx = Double(randomRange(min: 1, max: 32))
        ry = Double(randomRange(min: 1, max: 32))
        angleDegrees = Double(randomRange(min: 0, max: 360))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 3) {
        case 0:
            x = Double((Int(x) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y = Double((Int(y) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 1:
            rx = Double((Int(rx) + randomRange(min: -16, max: 16)).clamped(to: 1...xMax - 1))
        case 2:
            ry = Double((Int(ry) + randomRange(min: -16, max: 16)).clamped(to: 1...yMax - 1))
        case 3:
            angleDegrees = Double((Int(angleDegrees) + randomRange(min: -16, max: 16)).clamped(to: 0...360))
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
