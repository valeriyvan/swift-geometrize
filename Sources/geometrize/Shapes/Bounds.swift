import Foundation

public struct Bounds {
    let xMin: Int
    let xMax: Int
    let yMin: Int
    let yMax: Int

    public init(xMin: Int, xMax: Int, yMin: Int, yMax: Int) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }
}

