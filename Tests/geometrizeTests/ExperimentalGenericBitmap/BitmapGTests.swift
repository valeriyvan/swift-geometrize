import XCTest
import SnapshotTesting
import Foundation
@testable import Geometrize

// swiftlint:disable:next type_body_length
final class BitmapGTests: XCTestCase {

    func testInit() throws {
        let bitmap = BitmapG<Rgba8888>()
        XCTAssertEqual(bitmap.width, 0)
        XCTAssertEqual(bitmap.height, 0)
        XCTAssertEqual(bitmap.backing, [])
        XCTAssertTrue(bitmap.isEmpty)
    }

    func testInitJpegData() throws {
        let resource = "IMG_0180"
        let `extension` = "jpeg"
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let data = try Data(contentsOf: url)
        let bitmap = try BitmapG<Rgba8888>(jpegData: data)
        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testInitSizeAndColor() throws {
        let blackBitmap = BitmapG<Rgba8888>(width: 5, height: 7, color: Rgba8888(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(blackBitmap.width, 5)
        XCTAssertEqual(blackBitmap.height, 7)
        XCTAssertEqual(blackBitmap.backing.count, 5 * 7 * 4)
        XCTAssertEqual(blackBitmap.backing, ContiguousArray<UInt8>(repeating: 0, count: 5 * 7 * 4))
        XCTAssertFalse(blackBitmap.isEmpty)

        let whiteBitmap = Bitmap(width: 8, height: 6, color: .white)
        XCTAssertEqual(whiteBitmap.width, 8)
        XCTAssertEqual(whiteBitmap.height, 6)
        XCTAssertEqual(whiteBitmap.backing.count, 8 * 6 * 4)
        XCTAssertEqual(whiteBitmap.backing, ContiguousArray<UInt8>(repeating: 255, count: 8 * 6 * 4))
        XCTAssertFalse(whiteBitmap.isEmpty)
    }

    func testInitSizeAndBitmapData() throws {
        let data: [UInt8] = [
            0,0,0,0,     1,1,1,1,     2,2,2,2,     3,3,3,3,     4,4,4,4,     // swiftlint:disable:this comma
            10,10,10,10, 11,11,11,11, 12,12,12,12, 13,13,13,13, 14,14,14,14, // swiftlint:disable:this comma
            20,20,20,20, 21,21,21,21, 22,22,22,22, 23,23,23,23, 24,24,24,24  // swiftlint:disable:this comma
        ]
        let bitmap = BitmapG<Rgba8888>(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap.width, 5)
        XCTAssertEqual(bitmap.height, 3)
        XCTAssertEqual(bitmap.backing.count, 5 * 3 * 4)
        XCTAssertEqual(bitmap.backing, ContiguousArray<UInt8>(data))
    }

    func testInitSizeAndBitmapDataWithBackgroundBlended() throws {
        let bitmap = try BitmapG<Rgba8888>(pngBundleResource: "63", withExtension: "png")
        let bitmapWithYellowBackgroundBlended = BitmapG<Rgba8888>(
            width: bitmap.width,
            height: bitmap.height,
            data: bitmap.backing,
            blending: .yellow
        )
        assertSnapshot(
            of: bitmapWithYellowBackgroundBlended,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testInitInitializer() throws {
        XCTAssertEqual(
            BitmapG<Rgba8888>(width: 3, height: 4) {
                Rgba8888(r: UInt8($0 * $1),
                         g: UInt8($0 * $1 + 1),
                         b: UInt8($0 * $1 + 2),
                         a: UInt8($0 * $1 + 3)
                )
            },
            BitmapG<Rgba8888>(width: 3, height: 4,
                data:
                    [0,1,2,3, 0,1,2,3, 0,1,2,3, // swiftlint:disable:this comma
                     0,1,2,3, 1,2,3,4, 2,3,4,5, // swiftlint:disable:this comma
                     0,1,2,3, 2,3,4,5, 4,5,6,7, // swiftlint:disable:this comma
                     0,1,2,3, 3,4,5,6, 6,7,8,9  // swiftlint:disable:this comma
                    ]
            )
        )
    }

    func testIsEmpty() {
        XCTAssertTrue(BitmapG<Rgba8888>().isEmpty)
        XCTAssertTrue(BitmapG<Rgba8888>(width: 0, height: 2, color: .white).isEmpty)
        XCTAssertTrue(BitmapG<Rgba8888>(width: 2, height: 0, color: .white).isEmpty)
        XCTAssertTrue(BitmapG<Rgba8888>(width: 0, height: 0, color: .white).isEmpty)
        XCTAssertFalse(BitmapG<Rgba8888>(width: 3, height: 2, color: .white).isEmpty)
    }

    func testIsInBounds() {
        let bitmap = BitmapG<Rgba8888>(width: 3, height: 4, color: .cyan)
        XCTAssertTrue(bitmap.isInBounds(x: 2, y: 2))
        XCTAssertTrue(bitmap.isInBounds(Point(x: 2, y: 2)))
        XCTAssertTrue(bitmap.isInBounds(x: 0, y: 0))
        XCTAssertTrue(bitmap.isInBounds(Point(x: 0, y: 0)))
        XCTAssertTrue(bitmap.isInBounds(x: 2, y: 3))
        XCTAssertTrue(bitmap.isInBounds(Point(x: 2, y: 3)))
        XCTAssertFalse(bitmap.isInBounds(x: 3, y: 3))
        XCTAssertFalse(bitmap.isInBounds(x: 2, y: 5))
        XCTAssertFalse(bitmap.isInBounds(x: 3, y: 5))
        XCTAssertFalse(bitmap.isInBounds(Point(x: 3, y: 3)))
        XCTAssertFalse(bitmap.isInBounds(Point(x: 2, y: 5)))
        XCTAssertFalse(bitmap.isInBounds(Point(x: 3, y: 5)))

    }

    func testSubscript() throws {
        let data: [UInt8] = [
            0,0,0,0,     1,1,1,1,     2,2,2,2,     3,3,3,3,     4,4,4,4,     // swiftlint:disable:this comma
            10,10,10,10, 11,11,11,11, 12,12,12,12, 13,13,13,13, 14,14,14,14, // swiftlint:disable:this comma
            20,20,20,20, 21,21,21,21, 22,22,22,22, 23,23,23,23, 24,24,24,24  // swiftlint:disable:this comma
        ]
        var bitmap = BitmapG<Rgba8888>(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap[0, 0], Rgba8888(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(bitmap[Point(x: 0, y: 0)], Rgba8888(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(bitmap[4, 2], Rgba8888(r: 24, g: 24, b: 24, a: 24))
        XCTAssertEqual(bitmap[Point(x: 4, y: 2)], Rgba8888(r: 24, g: 24, b: 24, a: 24))
        XCTAssertEqual(bitmap[1, 1], Rgba8888(r: 11, g: 11, b: 11, a: 11))
        XCTAssertEqual(bitmap[Point(x: 1, y: 1)], Rgba8888(r: 11, g: 11, b: 11, a: 11))
        bitmap[1, 1] = Rgba8888(r: 111, g: 111, b: 111, a: 111)
        bitmap[Point(x: 3, y: 2)] = Rgba8888(r: 222, g: 222, b: 222, a: 222)
        XCTAssertEqual(
            bitmap.backing, [
                0,0,0,0,     1,1,1,1,         2,2,2,2,     3,3,3,3,         4,4,4,4,     // swiftlint:disable:this comma
                10,10,10,10, 111,111,111,111, 12,12,12,12, 13,13,13,13,     14,14,14,14, // swiftlint:disable:this comma
                20,20,20,20, 21,21,21,21,     22,22,22,22, 222,222,222,222, 24,24,24,24  // swiftlint:disable:this comma
            ] as ContiguousArray<UInt8>
        )
    }

    func testFill() throws {
        var bitmap = BitmapG<Rgba8888>(width: 5, height: 7, color: .black)
        let color = Rgba8888(r: 1, g: 2, b: 3, a: 128)
        bitmap.fill(color: color)
        let sampleBitmap = BitmapG<Rgba8888>(width: 5, height: 7, color: color)
        XCTAssertEqual(bitmap, sampleBitmap)
    }

    func testAverageColor() {
        XCTAssertEqual(BitmapG<Rgba8888>(width: 3, height: 5, color: .black).averageColor(), .black)
        XCTAssertEqual(BitmapG<Rgba8888>(width: 5, height: 3, color: .white).averageColor(), .white)

        let bitmap = BitmapG<Rgba8888>(
            width: 5,
            height: 3,
            data:
            [   0,0,0,0,     1,1,1,1,         2,2,2,2,     3,3,3,3,         4,4,4,4,     // swiftlint:disable:this comma
                10,10,10,10, 111,111,111,111, 12,12,12,12, 13,13,13,13,     14,14,14,14, // swiftlint:disable:this comma
                20,20,20,20, 21,21,21,21,     22,22,22,22, 222,222,222,222, 24,24,24,24  // swiftlint:disable:this comma
            ] as [UInt8]
        )
        XCTAssertEqual(bitmap.averageColor(), Rgba8888(r: 31, g: 31, b: 31, a: 31)) // TODO: this differs from Bitmap which returns 255 alpha
    }

    func testAddFrame() {
        let inset = 2
        var bitmap = BitmapG<Rgba8888>(width: 4, height: 3, color: .black)
        bitmap.addFrame(width: inset, color: .white)
        XCTAssertEqual(bitmap.width, 4 + inset * 2)
        XCTAssertEqual(bitmap.height, 3 + inset * 2)
        for x in 0..<bitmap.width {
            for y in 0..<bitmap.height {
                XCTAssertEqual(
                    bitmap[x, y],
                    (inset..<bitmap.width - inset ~= x) && (inset..<bitmap.height - inset ~= y) ? .black : .white
                )
            }
        }
    }

    func testTranspose() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = BitmapG<Rgba8888>(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(200)
        )
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 100.0, ry: 245.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .green.withAlphaComponent(200)
        )
        bitmap.draw(lines: scaleScanlinesTrimmed(width: width, height: height, step: 100), color: .black)

        bitmap.transpose()

        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testSwap() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = BitmapG<Rgba8888>(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red
        )

        bitmap.swap(x1: 10, y1: 10, x2: width / 2, y2: height / 2)

        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testReflectVertically() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = BitmapG<Rgba8888>(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(128)
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 350.0, y: 350.0, r: 200.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .yellow.withAlphaComponent(128)
        )

        bitmap.reflectVertically()

        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testReflectHorizontally() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = BitmapG<Rgba8888>(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red.withAlphaComponent(128)
        )
        bitmap.draw(
            lines:
                Circle(strokeWidth: 1, x: 350.0, y: 350.0, r: 200.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .yellow.withAlphaComponent(128)
        )

        bitmap.reflectHorizontally()

        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testRotateUp() throws {
        let f = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        var fUp = f
        fUp.rotateToUpOrientation(accordingTo: .up)
        XCTAssertEqual(f, fUp)
    }

    func testRotateUpMirrored() throws {
        var fUpMirrored = try BitmapG<Rgba8888>(pngBundleResource: "F-UpMirrored", withExtension: "png")
        fUpMirrored.rotateToUpOrientation(accordingTo: .upMirrored)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fUpMirrored, fUP)
    }

    func testRotateDown() throws {
        var fDown = try BitmapG<Rgba8888>(pngBundleResource: "F-Down", withExtension: "png")
        fDown.rotateToUpOrientation(accordingTo: .down)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fDown, fUP)
    }

    func testRotateDownMirrored() throws {
        var fDownMirrored = try BitmapG<Rgba8888>(pngBundleResource: "F-DownMirrored", withExtension: "png")
        fDownMirrored.rotateToUpOrientation(accordingTo: .downMirrored)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fDownMirrored, fUP)
    }

    func testRotateLeftMirrored() throws {
        var fLeftMirrored = try BitmapG<Rgba8888>(pngBundleResource: "F-LeftMirrored", withExtension: "png")
        fLeftMirrored.rotateToUpOrientation(accordingTo: .leftMirrored)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fLeftMirrored, fUP)
    }

    func testRotateLeft() throws {
        var fLeft = try BitmapG<Rgba8888>(pngBundleResource: "F-Left", withExtension: "png")
        fLeft.rotateToUpOrientation(accordingTo: .left)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fLeft, fUP)
    }

    func testRotateRightMirrored() throws {
        var fRightMirrored = try BitmapG<Rgba8888>(pngBundleResource: "F-RightMirrored", withExtension: "png")
        fRightMirrored.rotateToUpOrientation(accordingTo: .rightMirrored)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fRightMirrored, fUP)
    }

    func testRotateRight() throws {
        var fRight = try BitmapG<Rgba8888>(pngBundleResource: "F-Right", withExtension: "png")
        fRight.rotateToUpOrientation(accordingTo: .right)
        let fUP = try BitmapG<Rgba8888>(pngBundleResource: "F-Up", withExtension: "png")
        XCTAssertEqual(fRight, fUP)
    }

    func testBlend() throws {
        let bitmap = try BitmapG<Rgba8888>(pngBundleResource: "63", withExtension: "png")
        let bitmapWithWhiteBackgroundBlended = bitmap.blending(background: .white)
        assertSnapshot(
            of: bitmapWithWhiteBackgroundBlended,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
        let bitmapWithRedBackgroundBlended = bitmap.blending(background: .red)
        assertSnapshot(
            of: bitmapWithRedBackgroundBlended,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )
    }

    func testDraw() {
        var bitmap = BitmapG<Rgba8888>(width: 4, height: 5, color: .black)
        bitmap.draw(
            lines: [
                Scanline(y: 0, x1: 0, x2: 3),
                Scanline(y: 1, x1: 0, x2: 3),
                Scanline(y: 2, x1: 0, x2: 3),
                Scanline(y: 3, x1: 0, x2: 3),
                Scanline(y: 4, x1: 0, x2: 3)],
            color: .white
        )
        XCTAssertEqual(bitmap, BitmapG<Rgba8888>(width: 4, height: 5, color: .white))

        bitmap.draw(
            lines: [
                Scanline(y: 0, x1: 0, x2: 3),
                Scanline(y: 1, x1: 1, x2: 3),
                Scanline(y: 2, x1: 2, x2: 3),
                Scanline(y: 3, x1: 3, x2: 3)],
            color: .red
        )
        for x in 0..<4 {
            for y in 0..<5 {
                XCTAssertEqual(bitmap[x, y], y < 4 && x >= y ? .red : .white)
            }
        }
    }

    func testInitPpmString() throws { // swiftlint:disable:this function_body_length
        XCTAssertEqual(
            try BitmapG<Rgba8888>(ppmString:
            """
            P3
            3 2
            255
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18

            """),
            BitmapG<Rgba8888>(
                width: 3, height: 2,
                data: [
                    1, 2, 3, 255,
                    4, 5, 6, 255,
                    7, 8, 9, 255,
                    10, 11, 12, 255,
                    13, 14, 15, 255,
                    16, 17, 18, 255
                ]
            )
        )

        XCTAssertThrowsError(
            try BitmapG<Rgba8888>(ppmString:
            """
            P
            3 2
            255
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18

            """)
        ) { error in
            guard case BitmapG<Rgba8888>.ParsePpmError.noP3 = error else {
                return XCTFail("BitmapG<Rgba8888>.ParsePpmError.noP3 wasn't threw")
            }
        }

        XCTAssertThrowsError(
            try BitmapG<Rgba8888>(ppmString:
            """
            P3
            3 2
            500
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18

            """)
        ) { error in
            guard case BitmapG<Rgba8888>.ParsePpmError.maxElementNot255(let context) = error, context == "P3\n3 2\n500" else {
                return XCTFail("BitmapG<Rgba8888>.ParsePpmError.maxElementNot255 wasn't threw or context isn't as expected")
            }
        }

        XCTAssertThrowsError(
            try BitmapG<Rgba8888>(ppmString:
            """
            P3
            -10 2
            255
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18

            """)
        ) { error in
            guard case BitmapG<Rgba8888>.ParsePpmError.inconsistentHeader(let context) = error, context == "P3\n-10" else {
                return XCTFail("BitmapG<Rgba8888>.ParsePpmError.inconsistentHeader wasn't threw or context isn't as expected")
            }
        }

        XCTAssertThrowsError(
            try BitmapG<Rgba8888>(ppmString:
            """
            P3
            3 2
            255
            1 2 3
            4 5 6
            7 -1 9
            10 11 12
            13 14 15
            16 17 18

            """)
        ) { error in
            guard case BitmapG<Rgba8888>.ParsePpmError.wrongElement(let context) = error, context == "7 -1" else {
                return XCTFail("BitmapG<Rgba8888>.ParsePpmError.wrongElement wasn't threw or context isn't as expected")
            }
        }

        XCTAssertThrowsError(
            try BitmapG<Rgba8888>(ppmString:
            """
            P3
            3 2
            255
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18
            19

            """)
        ) { error in
            guard case BitmapG<Rgba8888>.ParsePpmError.excessiveCharacters(let context) = error, context == "19" else {
                return XCTFail("BitmapG<Rgba8888>.ParsePpmError.wrongElement wasn't threw or context isn't as expected")
            }
        }

        assertSnapshot(
            of: try BitmapG<Rgba8888>(ppmString: """
            P3
            # "P3" means this is a RGB color image in ASCII
            # "3 2" is the width and height of the image in pixels
            # "255" is the maximum value for each color
            # This, up through the "255" line below are the header.
            # Everything after that is the image data: RGB triplets.
            # In order: red, green, blue, yellow, white, and black.
            # This example is taken from https://en.wikipedia.org/wiki/Netpbm
            3 2
            255
            255   0   0
              0 255   0
              0   0 255
            255 255   0
            255 255 255
              0   0   0
            """
            ),
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<BitmapG>.image)
        )

    }

    func testPpmString() {
        XCTAssertEqual(
            BitmapG<Rgba8888>(
                width: 3, height: 2,
                data: [
                    1, 2, 3, 255,
                    4, 5, 6, 255,
                    7, 8, 9, 255,
                    10, 11, 12, 255,
                    13, 14, 15, 255,
                    16, 17, 18, 255
                ]
            )
            .ppmString(background: .white),
            """
            P3
            3 2
            255
            1 2 3
            4 5 6
            7 8 9
            10 11 12
            13 14 15
            16 17 18

            """
        )
    }

    func testDifferenceFull() throws {
        let blackBitmap = BitmapG<Rgba8888>(width: 10, height: 10, color: .black)

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
        let whiteBitmap = BitmapG<Rgba8888>(width: 10, height: 10, color: .white)

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
/*
    func testDifferenceFullVectorized() throws {
        let blackBitmap = Bitmap(width: 10, height: 10, color: .black)

        // Difference with itself is 0
        XCTAssertEqual(blackBitmap.differenceFullVectorized(with: blackBitmap), 0)

        var blackBitmapOnePixelChanged = blackBitmap
        blackBitmapOnePixelChanged[0, 0] = .white
        var blackBitmapTwoPixelsChanged = blackBitmapOnePixelChanged
        blackBitmapTwoPixelsChanged[0, 1] = .white

        // Changing two pixels means there's more difference than changing one.
        XCTAssertGreaterThan(
            blackBitmap.differenceFullVectorized(with: blackBitmapTwoPixelsChanged),
            blackBitmap.differenceFullVectorized(with: blackBitmapOnePixelChanged)
        )

        // Now the same for white image
        let whiteBitmap = Bitmap(width: 10, height: 10, color: .white)

        // Difference with itself is 0
        XCTAssertEqual(whiteBitmap.differenceFullVectorized(with: whiteBitmap), 0)

        var whiteBitmapOnePixelChanged = whiteBitmap
        whiteBitmapOnePixelChanged[0, 0] = .black
        var whiteBitmapTwoPixelsChanged = whiteBitmapOnePixelChanged
        whiteBitmapTwoPixelsChanged[0, 1] = .black

        // Changing two pixels means there's more difference than changing one.
        XCTAssertGreaterThan(
            whiteBitmap.differenceFullVectorized(with: whiteBitmapTwoPixelsChanged),
            whiteBitmap.differenceFullVectorized(with: whiteBitmapOnePixelChanged)
        )
    }
*/
    func testDifferenceFullComparingResultWithCPlusPlus() throws {
        let bitmapFirst = try Bitmap(ppmBundleResource: "differenceFull bitmap first", withExtension: "ppm")
        let bitmapSecond = try Bitmap(ppmBundleResource: "differenceFull bitmap second", withExtension: "ppm")
        XCTAssertEqual(bitmapFirst.differenceFull(with: bitmapSecond), 0.170819, accuracy: 0.000001)
    }
/*
    func testDifferenceFullVectorizedComparingResultWithCPlusPlus() throws {
        let bitmapFirst = try Bitmap(ppmBundleResource: "differenceFull bitmap first", withExtension: "ppm")
        let bitmapSecond = try Bitmap(ppmBundleResource: "differenceFull bitmap second", withExtension: "ppm")
        XCTAssertEqual(bitmapFirst.differenceFullVectorized(with: bitmapSecond), 0.170819, accuracy: 0.000001)
    }
*/
    func testDifferencePartialComparingResultWithCPlusPlus() throws {
        let bitmapTarget = try BitmapG<Rgba8888>(ppmBundleResource: "differencePartial bitmap target", withExtension: "ppm")
        let bitmapBefore = try BitmapG<Rgba8888>(ppmBundleResource: "differencePartial bitmap before", withExtension: "ppm")
        let bitmapAfter = try BitmapG<Rgba8888>(ppmBundleResource: "differencePartial bitmap after", withExtension: "ppm")
        let scanlines = try [Scanline](stringBundleResource: "differencePartial scanlines", withExtension: "txt")
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
/*
    func testDifferencePartialVectorizedComparingResultWithCPlusPlus() throws {
        let bitmapTarget = try Bitmap(ppmBundleResource: "differencePartial bitmap target", withExtension: "ppm")
        let bitmapBefore = try Bitmap(ppmBundleResource: "differencePartial bitmap before", withExtension: "ppm")
        let bitmapAfter = try Bitmap(ppmBundleResource: "differencePartial bitmap after", withExtension: "ppm")
        let scanlines = try [Scanline](stringBundleResource: "differencePartial scanlines", withExtension: "txt")
        XCTAssertEqual(
            bitmapBefore.differencePartialVectorized(
                with: bitmapAfter,
                target: bitmapTarget,
                score: 0.170819,
                mask: scanlines
            ),
            0.170800,
            accuracy: 0.000001
        )
    }
*/
}

// swiftlint:disable:this file_length
