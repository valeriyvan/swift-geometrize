import XCTest
@testable import Geometrize

final class DefaultEnergyFunctionTests: XCTestCase {

    func testDefaultEnergyFunctionComparingResultWithCPlusPlus() throws {
        let scanlines = try [Scanline](
            stringBundleResource: "defaultEnergyFunction scanlines",
            withExtension: "txt"
        )
        let bitmapTarget = try Bitmap(
            ppmBundleResource: "defaultEnergyFunction target bitmap",
            withExtension: "ppm"
        )
        let bitmapCurrent = try Bitmap(
            ppmBundleResource: "defaultEnergyFunction current bitmap",
            withExtension: "ppm"
        )
        var bitmapBuffer = try Bitmap(
            ppmBundleResource: "defaultEnergyFunction buffer bitmap",
            withExtension: "ppm"
        )
        let bitmapBufferOnExit = try Bitmap(
            ppmBundleResource: "defaultEnergyFunction buffer bitmap on exit",
            withExtension: "ppm"
        )

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

}
