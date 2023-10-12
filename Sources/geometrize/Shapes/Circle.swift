import Foundation

public final class Circle: Shape {
    public var x: Double // x-coordinate.
    public var y: Double // y-coordinate.
    public var r: Double // Radius.

    public init() {
        x = 0.0
        y = 0.0
        r = 0.0
    }

    public init(x: Double, y: Double, r: Double) {
        self.x = x
        self.y = y
        self.r = r
    }

    public func copy() -> Circle {
        Circle(x: x, y: y, r: r)
    }

    public func setup(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>, using generator: inout SplitMix64) {
        x = Double(Int._random(in: xRange, using: &generator))
        y = Double(Int._random(in: yRange, using: &generator))
        r = Double(Int._random(in: 1...32, using: &generator))
    }

    public func mutate(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>, using generator: inout SplitMix64) {
        let range16 = -16...16
        switch Int._random(in: 0...1, using: &generator) {
        case 0:
            x = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            y = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
        case 1:
            r = Double((Int(r) + Int._random(in: range16, using: &generator)).clamped(to: 1...xRange.upperBound))
        default:
            fatalError()
        }
    }

    public func rasterize(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>) -> [Scanline] {
        var lines: [Scanline] = []
        let r = Int(r)
        let r² = r * r
        let rRange = -r...r
        for y in rRange {
            var xScan: [Int] = []
            let y² = y * y
            for x in rRange where x * x + y² <= r² {
                xScan.append(x)
            }
            guard let xScanFirst = xScan.first, let xScanLast = xScan.last else { continue }
            let fy = Int(self.y) + y
            let intX = Int(x)
            let x1 = (intX + xScanFirst).clamped(to: xRange)
            let x2 = (intX + xScanLast).clamped(to: xRange)
            if let line = Scanline(y: fy, x1: x1, x2: x2).trimmed(x: xRange, y: yRange) {
                lines.append(line)
            }
        }
        if lines.isEmpty {
            print("Warning: \(#function) produced no scanlines")
        }
        return lines
    }

    public var isDegenerate: Bool {
        r == 0.0
    }

    public var description: String {
        "Circle(x=\(x), y=\(y), r=\(r))"
    }

}
