import Foundation

public final class Ellipse: Shape {
    public var x: Double // x-coordinate.
    public var y: Double // y-coordinate.
    public var rx: Double // x-radius.
    public var ry: Double // y-radius.

    public init() {
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
    }

    public init(x: Double, y: Double, rx: Double, ry: Double) {
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
    }

    public func copy() -> Ellipse {
        Ellipse(x: x, y: y, rx: rx, ry: ry)
    }

    public func setup(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        x = Double(Int._random(in: xMin...xMax, using: &generator))
        y = Double(Int._random(in: yMin...yMax, using: &generator))
        rx = Double(Int._random(in: 1...32, using: &generator))
        ry = Double(Int._random(in: 1...32, using: &generator))
    }

    public func mutate(xMin: Int, yMin: Int, xMax: Int, yMax: Int, using generator: inout SplitMix64) {
        let range16 = -16...16
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            x = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xMin...xMax))
            y = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yMin...yMax))
        case 1:
            rx = Double((Int(rx) + Int._random(in: range16, using: &generator)).clamped(to: 1...xMax))
        case 2:
            ry = Double((Int(ry) + Int._random(in: range16, using: &generator)).clamped(to: 1...yMax))
        default:
            fatalError()
        }
    }

    public func rasterize(xMin: Int, yMin: Int, xMax: Int, yMax: Int) -> [Scanline] {
        var lines: [Scanline] = []
        let aspect = rx / ry
        for dy in 0..<Int(ry) {
            let y1 = Int(y) - dy
            let y2 = Int(y) + dy
            if (y1 < yMin || y1 >= yMax) && (y2 < yMin || y2 >= yMax) {
                continue
            }
            let v: Int = Int(sqrt(ry * ry - Double(dy * dy)) * aspect)
            var x1: Int = Int(x) - v
            if x1 < xMin {
                x1 = xMin
            }
            var x2: Int = Int(x) + v
            if x2 >= xMax {
                x2 = xMax - 1
            }
            if y1 >= xMin && y1 < yMax {
                if let line = Scanline(y: y1, x1: x1, x2: x2).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) {
                    lines.append(line)
                }
            }
            if y2 >= yMin && y2 < yMax && dy > 0 {
                if let line = Scanline(y: y2, x1: x1, x2: x2).trimmed(minX: xMin, minY: yMin, maxX: xMax, maxY: yMax) {
                    lines.append(line)
                }
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public func type() -> ShapeType {
        .ellipse
    }

    public var isDegenerate: Bool {
        rx == 0.0 || ry == 0.0
    }

    public var description: String {
        "Ellipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry))"
    }

}
