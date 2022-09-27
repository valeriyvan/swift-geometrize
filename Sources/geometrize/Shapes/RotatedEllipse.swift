import Foundation

// Represents a rotated ellipse.
final class RotatedEllipse: Shape {
    
    public var x: Double // x-coordinate.
    public var y: Double // y-coordinate.
    public var rx: Double // x-radius.
    public var ry: Double // y-radius.
    public var angle: Double // Rotation angle.
    
    required init() {
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
        angle = 0.0
    }
    
    init(x: Double, y: Double, rx: Double, ry: Double, angle: Double) {
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
        self.angle = angle
    }
    
    func copy() -> RotatedEllipse {
        RotatedEllipse(x: x, y: y, rx: rx, ry: ry, angle: angle)
    }

    func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        x = Double(randomRange(min: xMin, max: xMax - 1))
        y = Double(randomRange(min: yMin, max: yMax - 1))
        rx = Double(randomRange(min: 1, max: 32))
        ry = Double(randomRange(min: 1, max: 32))
        angle = Double(randomRange(min: 0, max: 360))
    }

    func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int) {
        switch randomRange(min: 0, max: 3) {
        case 0:
            x = Double((Int(x) + randomRange(min: -16, max: 16)).clamped(to: xMin...xMax - 1))
            y = Double((Int(y) + randomRange(min: -16, max: 16)).clamped(to: yMin...yMax - 1))
        case 1:
            rx = Double((Int(rx) + randomRange(min: -16, max: 16)).clamped(to: 1...xMax - 1))
        case 2:
            ry = Double((Int(ry) + randomRange(min: -16, max: 16)).clamped(to: 1...yMax - 1))
        case 3:
            angle = Double((Int(angle) + randomRange(min: -16, max: 16)).clamped(to: 0...360))
        default:
            fatalError()
        }
    }

    func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        let lines =
        try! Polygon(vertices: points(20)
            .map(Point<Int>.init))
        .scanlines()
        .trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax)
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    private func points(_ count: Int) -> [Point<Double>] {
        let rads = angle * (.pi / 180.0)
        let co = cos(rads)
        let si = sin(rads)
        var points = [Point<Double>]()
        for i in 0..<count {
            let angle = 360.0 / Double(count) * Double(i) * (.pi / 180.0)
            let crx = rx * cos(angle)
            let cry = ry * sin(angle)
            points.append(Point(x: crx * co - cry * si + x, y: crx * si + cry * co + y))
        }
        return points
    }
    
    func type() -> ShapeType {
        .rotatedEllipse
    }
    
    var description: String {
        "RotatedEllipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry), angle=\(angle))"
    }

}
