import Foundation

// Represents a rotated ellipse.
public struct RotatedEllipse: Shape {
    public let strokeWidth: Double
    public let x: Double // x-coordinate.
    public let y: Double // y-coordinate.
    public let rx: Double // x-radius.
    public let ry: Double // y-radius.
    public let angleDegrees: Double // Rotation angle in degrees.

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
        angleDegrees = 0.0
    }

    public init(strokeWidth: Double, x: Double, y: Double, rx: Double, ry: Double, angleDegrees: Double) {
        self.strokeWidth = strokeWidth
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
        self.angleDegrees = angleDegrees
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> RotatedEllipse {
        let range32 = 1...32
        return RotatedEllipse(
            strokeWidth: strokeWidth,
            x: Double(Int._random(in: xRange, using: &generator)),
            y: Double(Int._random(in: yRange, using: &generator)),
            rx: Double(Int._random(in: range32, using: &generator)),
            ry: Double(Int._random(in: range32, using: &generator)),
            angleDegrees: Double(Int._random(in: 0...360, using: &generator))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> RotatedEllipse {
        let range16 = -16...16
        var newX, newY, newRx, newRy, newAngleDegrees: Double
        switch Int._random(in: 0...3, using: &generator) {
        case 0:
            newX = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newRx = rx
            newRy = ry
            newAngleDegrees = angleDegrees
        case 1:
            newX = x
            newY = y
            newRx = Double((Int(rx) + Int._random(in: range16, using: &generator)).clamped(to: 1...xRange.upperBound))
            newRy = ry
            newAngleDegrees = angleDegrees
        case 2:
            newX = x
            newY = y
            newRx = rx
            newRy = Double((Int(ry) + Int._random(in: range16, using: &generator)).clamped(to: 1...yRange.upperBound))
            newAngleDegrees = angleDegrees
        case 3:
            newX = x
            newY = y
            newRx = rx
            newRy = ry
            newAngleDegrees = Double(
                (Int(angleDegrees) + Int._random(in: range16, using: &generator)).clamped(to: 0...360)
            )
        default:
            fatalError("Internal inconsistency")
        }
        return RotatedEllipse(
            strokeWidth: strokeWidth,
            x: newX,
            y: newY,
            rx: newRx,
            ry: newRy,
            angleDegrees: newAngleDegrees
        )
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        guard let polygon = try? Polygon(vertices: points(20).map(Point<Int>.init)) else {
            print("Warning: \(#function) produced no scanlines.")
            return []
        }
        let lines = polygon
            .scanlines()
            .trimmed(x: xRange, y: yRange)
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

    public var isDegenerate: Bool {
        rx == 0.0 || ry == 0.0
    }

    public var description: String {
        "RotatedEllipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry), angleDegrees=\(angleDegrees))"
    }

}
