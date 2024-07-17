import Foundation

public struct Circle: Shape {
    public let strokeWidth: Double
    public let x: Double // x-coordinate.
    public let y: Double // y-coordinate.
    public let r: Double // Radius.

    public init(strokeWidth: Double) {
        self.strokeWidth = strokeWidth
        x = 0.0
        y = 0.0
        r = 0.0
    }

    public init(strokeWidth: Double, x: Double, y: Double, r: Double) {
        self.strokeWidth = strokeWidth
        self.x = x
        self.y = y
        self.r = r
    }

    public func setup(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Circle {
        Circle(
            strokeWidth: strokeWidth,
            x: Double(Int._random(in: xRange, using: &generator)),
            y: Double(Int._random(in: yRange, using: &generator)),
            r: Double(Int._random(in: 1...32, using: &generator))
        )
    }

    public func mutate(
        x xRange: ClosedRange<Int>,
        y yRange: ClosedRange<Int>,
        using generator: inout SplitMix64
    ) -> Circle {
        let range16 = -16...16
        var newX, newY, newR: Double
        switch Int._random(in: 0...1, using: &generator) {
        case 0:
            newX = Double((Int(x) + Int._random(in: range16, using: &generator)).clamped(to: xRange))
            newY = Double((Int(y) + Int._random(in: range16, using: &generator)).clamped(to: yRange))
            newR = r
        case 1:
            newX = x
            newY = y
            newR = Double((Int(r) + Int._random(in: range16, using: &generator)).clamped(to: 1...xRange.upperBound))
        default:
            fatalError("Internal inconsistency")
        }
        return Circle(strokeWidth: strokeWidth, x: newX, y: newY, r: newR)
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
