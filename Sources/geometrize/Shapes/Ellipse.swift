import Foundation

public struct Ellipse: Shape {
    public let strokeWidth: Double
    public let x: Double // x-coordinate.
    public let y: Double // y-coordinate.
    public let rx: Double // x-radius.
    public let ry: Double // y-radius.

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x = 0.0
        y = 0.0
        rx = 0.0
        ry = 0.0
    }

    public init(strokeWidth: Double, x: Double, y: Double, rx: Double, ry: Double) {
        self.strokeWidth = strokeWidth
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Ellipse {
        Ellipse(
            strokeWidth: strokeWidth,
            x: Double(Int._random(in: xRange, using: &generator)),
            y: Double(Int._random(in: yRange, using: &generator)),
            rx: Double(Int._random(in: 1...32, using: &generator)),
            ry: Double(Int._random(in: 1...32, using: &generator))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Ellipse {
        let range16 = -16...16
        let newX, newY, newRx, newRy: Double
        switch Int._random(in: 0...2, using: &generator) {
        case 0:
            newX = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newRx = rx
            newRy  = ry
        case 1:
            newX = x
            newY = y
            newRx = Double((Int(rx) + Int._random(in: range16, using: &generator)).clamped(to: 1...xRange.upperBound))
            newRy = ry
        case 2:
            newX = x
            newY = y
            newRx = rx
            newRy = Double((Int(ry) + Int._random(in: range16, using: &generator)).clamped(to: 1...yRange.upperBound))
        default:
            fatalError("Internal inconsistency")
        }
        return Ellipse(strokeWidth: strokeWidth, x: newX, y: newY, rx: newRx, ry: newRy)
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        var lines: [Scanline] = []
        let aspect = rx / ry
        for dy in 0..<Int(ry) {
            let y1 = Int(y) - dy
            let y2 = Int(y) + dy
            if !(yRange ~= y1) && !(yRange ~= y2) {
                continue
            }
            let v: Int = Int(sqrt(ry * ry - Double(dy * dy)) * aspect)
            let x1: Int = (Int(x) - v).clamped(to: xRange)
            let x2: Int = (Int(x) + v).clamped(to: xRange)
            if yRange ~= y1 {
                if let line = Scanline(y: y1, x1: x1, x2: x2).trimmed(x: xRange, y: yRange) {
                    lines.append(line)
                }
            }
            if yRange ~= y2 && dy > 0 {
                if let line = Scanline(y: y2, x1: x1, x2: x2).trimmed(x: xRange, y: yRange) {
                    lines.append(line)
                }
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var isDegenerate: Bool {
        rx == 0.0 || ry == 0.0
    }

    public var description: String {
        "Ellipse(x=\(x), y=\(y), rx=\(rx), ry=\(ry))"
    }

}
