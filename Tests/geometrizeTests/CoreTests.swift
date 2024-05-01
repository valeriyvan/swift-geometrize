import XCTest
@testable import Geometrize

final class CoreTests: XCTestCase {

    func testDifferenceFull() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)

        // Difference with itself is 0
        XCTAssertEqual(blackBitmap.differenceFull(with: blackBitmap), 0)

        var blackBitmapOnePixelChanged = blackBitmap
        blackBitmapOnePixelChanged[0, 0] = .white
        var blackBitmapTwoPixelsChanged = blackBitmapOnePixelChanged
        blackBitmapTwoPixelsChanged[0, 1] = .white

        // Changing two pixels means there's more difference than changing one.
        XCTAssertGreaterThan(
            blackBitmap.differenceFull(with: blackBitmapTwoPixelsChanged),
            blackBitmap.differenceFull(with: blackBitmapOnePixelChanged)
        )

        // Now the same for white image
        let whiteBitmap = Bitmap(width: 10, height: 10, color: .white)

        // Difference with itself is 0
        XCTAssertEqual(whiteBitmap.differenceFull(with: whiteBitmap), 0)

        var whiteBitmapOnePixelChanged = whiteBitmap
        whiteBitmapOnePixelChanged[0, 0] = .black
        var whiteBitmapTwoPixelsChanged = whiteBitmapOnePixelChanged
        whiteBitmapTwoPixelsChanged[0, 1] = .black

        // Changing two pixels means there's more difference than changing one.
        XCTAssertGreaterThan(
            whiteBitmap.differenceFull(with: whiteBitmapTwoPixelsChanged),
            whiteBitmap.differenceFull(with: whiteBitmapOnePixelChanged)
        )
    }

    func testDifferenceFullComparingResultWithCPlusPlus() throws {
        let firstUrl = Bundle.module.url(forResource: "differenceFull bitmap first", withExtension: "txt")!
        let bitmapFirst = Bitmap(stringLiteral: try String(contentsOf: firstUrl))
        let secondUrl = Bundle.module.url(forResource: "differenceFull bitmap second", withExtension: "txt")!
        let bitmapSecond = Bitmap(stringLiteral: try String(contentsOf: secondUrl))
        XCTAssertEqual(bitmapFirst.differenceFull(with: bitmapSecond), 0.170819, accuracy: 0.000001)
    }

    func testDifferencePartialComparingResultWithCPlusPlus() throws {
        let bitmapTargetUrl = Bundle.module.url(forResource: "differencePartial bitmap target", withExtension: "txt")!
        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: bitmapTargetUrl))
        let bitmapBeforeUrl = Bundle.module.url(forResource: "differencePartial bitmap before", withExtension: "txt")!
        let bitmapBefore = Bitmap(stringLiteral: try String(contentsOf: bitmapBeforeUrl))
        let bitmapAfterUrl = Bundle.module.url(forResource: "differencePartial bitmap after", withExtension: "txt")!
        let bitmapAfter = Bitmap(stringLiteral: try String(contentsOf: bitmapAfterUrl))

        let scanlinesUrl = Bundle.module.url(forResource: "differencePartial scanlines", withExtension: "txt")!
        let scanlinesString = try String(contentsOf: scanlinesUrl)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        let scanlines = components.map(Scanline.init)

        XCTAssertEqual(
            bitmapBefore.differencePartial(
                with: bitmapAfter,
                target: bitmapTarget,
                score: 0.170819,
                mask: scanlines
            ),
            0.170800,
            accuracy: 0.000001
        )
    }

    func testDefaultEnergyFunctionComparingResultWithCPlusPlus() throws {
        let scanlinesUrl = Bundle.module.url(
            forResource: "defaultEnergyFunction scanlines",
            withExtension: "txt"
        )!
        let scanlinesString = try String(contentsOf: scanlinesUrl)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        let scanlines = components.map(Scanline.init)

        let targetUrl = Bundle.module.url(
            forResource: "defaultEnergyFunction target bitmap",
            withExtension: "txt"
        )!
        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: targetUrl))
        let currentUrl = Bundle.module.url(
            forResource: "defaultEnergyFunction current bitmap",
            withExtension: "txt"
        )!
        let bitmapCurrent = Bitmap(stringLiteral: try String(contentsOf: currentUrl))
        let bufferUrl = Bundle.module.url(
            forResource: "defaultEnergyFunction buffer bitmap",
            withExtension: "txt"
        )!
        var bitmapBuffer = Bitmap(stringLiteral: try String(contentsOf: bufferUrl))
        let bufferOnExitUrl = Bundle.module.url(
            forResource: "defaultEnergyFunction buffer bitmap on exit",
            withExtension: "txt"
        )!
        let bitmapBufferOnExit = Bitmap(stringLiteral: try String(contentsOf: bufferOnExitUrl))

        XCTAssertEqual(
            defaultEnergyFunction(
                scanlines,
                128 /* alpha */,
                bitmapTarget,
                bitmapCurrent,
                &bitmapBuffer,
                0.162824
            ),
            0.162776,
            accuracy: 0.000001
        )

        XCTAssertEqual(bitmapBuffer, bitmapBufferOnExit)
    }

    // fails
    func testHillClimbComparingResultWithCPlusPlus() throws {
        let url = Bundle.module.url(forResource: "hillClimb randomRange", withExtension: "txt")!
        let randomNumbersString = try String(contentsOf: url)
        let lines = randomNumbersString.components(separatedBy: .newlines)
        var counter = 0
        func randomRangeFromFile(in range: ClosedRange<Int>, using generator: inout SplitMix64) -> Int {
            defer { counter += 1 }
            let line = lines[counter]
            let scanner = Scanner(string: line)
            scanner.charactersToBeSkipped = .whitespacesAndNewlines
            guard
                let random = scanner.scanInt(),
                scanner.scanString("(min:") != nil,
                let theMin = scanner.scanInt(),
                scanner.scanString(",max:") != nil,
                let theMax = scanner.scanInt(),
                theMin == range.lowerBound, theMax == range.upperBound
            else {
                fatalError()
            }
            return random
        }
        _randomImplementationReference = randomRangeFromFile

        let urlTarget = Bundle.module.url(forResource: "hillClimb target bitmap", withExtension: "txt")!
        let bitmapTarget = Bitmap(stringLiteral: try String(contentsOf: urlTarget))
        let urlCurrent = Bundle.module.url(forResource: "hillClimb current bitmap", withExtension: "txt")!
        let bitmapCurrent = Bitmap(stringLiteral: try String(contentsOf: urlCurrent))
        let urlBuffer = Bundle.module.url(forResource: "hillClimb buffer bitmap", withExtension: "txt")!
        var bitmapBuffer = Bitmap(stringLiteral: try String(contentsOf: urlBuffer))
        let urlBufferOnExit = Bundle.module.url(forResource: "hillClimb buffer bitmap on exit", withExtension: "txt")!
        let bitmapBufferOnExit = Bitmap(stringLiteral: try String(contentsOf: urlBufferOnExit))

        let rectangle = Rectangle(strokeWidth: 1, x1: 281, y1: 193, x2: 309, y2: 225)
        // rectangle.setupImplementation = { r in
        //     r.setup(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangle.mutateImplementation = { r in
        //     r.mutate(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangle.rasterizeImplementation = { r in
        //     rectangle.rasterize(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        let state = State(score: 0.169823, alpha: 128, shape: rectangle)

        // hillClimb return state State(score: 0.162824, alpha: 128, shape: Rectangle(x1=272,y1=113,x2=355,y2=237))

        let rectangleOnExit = Rectangle(strokeWidth: 1, x1: 272, y1: 113, x2: 355, y2: 237)
        // rectangleOnExit.setupImplementation = { r in
        //     r.setup(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangleOnExit.mutateImplementation = { r in
        //     r.mutate(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        // rectangleOnExit.rasterizeImplementation = { r in
        //     r.rasterize(xMin: 0, yMin: 0, xMax: bitmapTarget.width, yMax: bitmapTarget.height)
        // }
        let stateOnExitSample = State(score: 0.162824, alpha: 128, shape: rectangleOnExit)

        var generator = SplitMix64(seed: 9999)

        let stateOnExit = hillClimb(
            state: state,
            maxAge: 100,
            target: bitmapTarget,
            current: bitmapCurrent,
            buffer: &bitmapBuffer,
            lastScore: 0.170819,
            energyFunction: defaultEnergyFunction,
            using: &generator
        )

        // ("0.15865964089795329") is not equal to ("0.162824") +/- ("1e-06")
        XCTAssertEqual(stateOnExit.score, stateOnExitSample.score, accuracy: 0.000001)
        XCTAssertEqual(stateOnExit.alpha, stateOnExitSample.alpha)
        XCTAssertTrue(stateOnExit.shape == stateOnExitSample.shape) // XCTAssertTrue failed

        XCTAssertEqual(bitmapBuffer, bitmapBufferOnExit) // XCTAssertEqual
    }

}

func == (lhs: any Shape, rhs: any Shape) -> Bool {
    switch (lhs, rhs) {
    case (let lhs as Circle, let rhs as Circle): return lhs == rhs
    case (let lhs as Ellipse, let rhs as Ellipse): return lhs == rhs
    case (let lhs as Line, let rhs as Line): return lhs == rhs
    case (let lhs as Polyline, let rhs as Polyline): return lhs == rhs
    case (let lhs as QuadraticBezier, let rhs as QuadraticBezier): return lhs == rhs
    case (let lhs as Rectangle, let rhs as Rectangle): return lhs == rhs
    case (let lhs as RotatedRectangle, let rhs as RotatedRectangle): return lhs == rhs
    default: return false
    }
}
