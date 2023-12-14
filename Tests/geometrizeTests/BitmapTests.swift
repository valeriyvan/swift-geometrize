import XCTest
import SnapshotTesting
@testable import Geometrize

final class BitmapTests: XCTestCase {

    func testInit() throws {
        let bitmap = Bitmap()
        XCTAssertEqual(bitmap.width, 0)
        XCTAssertEqual(bitmap.height, 0)
        XCTAssertEqual(bitmap.backing, [])
        XCTAssertTrue(bitmap.isEmpty)
    }

    func testInitSizeAndColor() throws {
        let blackBitmap = Bitmap(width: 5, height: 7, color: Rgba(r: 0, g: 0, b: 0, a: 0))
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

    func testInitSizeAndBitmap() throws {
        let data: [UInt8] = [
            0,0,0,0,     1,1,1,1,     2,2,2,2,     3,3,3,3,     4,4,4,4,     // swiftlint:disable:this comma
            10,10,10,10, 11,11,11,11, 12,12,12,12, 13,13,13,13, 14,14,14,14, // swiftlint:disable:this comma
            20,20,20,20, 21,21,21,21, 22,22,22,22, 23,23,23,23, 24,24,24,24  // swiftlint:disable:this comma
        ]
        let bitmap = Bitmap(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap.width, 5)
        XCTAssertEqual(bitmap.height, 3)
        XCTAssertEqual(bitmap.backing.count, 5 * 3 * 4)
        XCTAssertEqual(bitmap.backing, ContiguousArray<UInt8>(data))
    }

    func testInitInitializer() throws {
        XCTAssertEqual(
            Bitmap(width: 3, height: 4) {
                Rgba(r: UInt8($0 * $1),
                     g: UInt8($0 * $1 + 1),
                     b: UInt8($0 * $1 + 2),
                     a: UInt8($0 * $1 + 3)
                )
            },
            Bitmap(width: 3, height: 4,
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
        XCTAssertTrue(Bitmap().isEmpty)
        XCTAssertTrue(Bitmap(width: 0, height: 2, color: .white).isEmpty)
        XCTAssertTrue(Bitmap(width: 2, height: 0, color: .white).isEmpty)
        XCTAssertTrue(Bitmap(width: 0, height: 0, color: .white).isEmpty)
        XCTAssertFalse(Bitmap(width: 3, height: 2, color: .white).isEmpty)
    }

    func testIsInBounds() {
        let bitmap = Bitmap(width: 3, height: 4, color: .cyan)
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
        var bitmap = Bitmap(width: 5, height: 3, data: data)
        XCTAssertEqual(bitmap[0, 0], Rgba(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(bitmap[Point(x: 0, y: 0)], Rgba(r: 0, g: 0, b: 0, a: 0))
        XCTAssertEqual(bitmap[4, 2], Rgba(r: 24, g: 24, b: 24, a: 24))
        XCTAssertEqual(bitmap[Point(x: 4, y: 2)], Rgba(r: 24, g: 24, b: 24, a: 24))
        XCTAssertEqual(bitmap[1, 1], Rgba(r: 11, g: 11, b: 11, a: 11))
        XCTAssertEqual(bitmap[Point(x: 1, y: 1)], Rgba(r: 11, g: 11, b: 11, a: 11))
        bitmap[1, 1] = Rgba(r: 111, g: 111, b: 111, a: 111)
        bitmap[Point(x: 3, y: 2)] = Rgba(r: 222, g: 222, b: 222, a: 222)
        XCTAssertEqual(
            bitmap.backing, [
                0,0,0,0,     1,1,1,1,         2,2,2,2,     3,3,3,3,         4,4,4,4,     // swiftlint:disable:this comma
                10,10,10,10, 111,111,111,111, 12,12,12,12, 13,13,13,13,     14,14,14,14, // swiftlint:disable:this comma
                20,20,20,20, 21,21,21,21,     22,22,22,22, 222,222,222,222, 24,24,24,24  // swiftlint:disable:this comma
            ] as ContiguousArray<UInt8>
        )
    }

    func testFill() throws {
        var bitmap = Bitmap(width: 5, height: 7, color: .black)
        let color = Rgba(r: 1, g: 2, b: 3, a: 128)
        bitmap.fill(color: color)
        let sampleBitmap = Bitmap(width: 5, height: 7, color: color)
        XCTAssertEqual(bitmap, sampleBitmap)
    }

    func testAverageColor() {
        XCTAssertEqual(Bitmap(width: 3, height: 5, color: .black).averageColor(), .black)
        XCTAssertEqual(Bitmap(width: 5, height: 3, color: .white).averageColor(), .white)

        let bitmap = Bitmap(
            width: 5,
            height: 3,
            data:
                [ 0,0,0,0,     1,1,1,1,         2,2,2,2,     3,3,3,3,         4,4,4,4,     // swiftlint:disable:this comma
                  10,10,10,10, 111,111,111,111, 12,12,12,12, 13,13,13,13,     14,14,14,14, // swiftlint:disable:this comma
                  20,20,20,20, 21,21,21,21,     22,22,22,22, 222,222,222,222, 24,24,24,24  // swiftlint:disable:this comma
                ] as [UInt8]
        )
        XCTAssertEqual(bitmap.averageColor(), Rgba(r: 31, g: 31, b: 31, a: 255))
    }

    func testAddFrame() {
        let inset = 2
        var bitmap = Bitmap(width: 4, height: 3, color: .black)
        bitmap.addFrame(width: inset, color: .white)
        XCTAssertEqual(bitmap.width, 4 + inset * 2)
        XCTAssertEqual(bitmap.height, 3 + inset * 2)
        for x in 0..<bitmap.width {
            for y in 0..<bitmap.height {
                let color: Rgba = (inset..<bitmap.width - inset ~= x) && (inset..<bitmap.height - inset ~= y) ? .black : .white
                XCTAssertEqual(bitmap[x, y], color)
            }
        }
    }

    func testTranspose() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
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
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testSwap() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines:
                Ellipse(strokeWidth: 1, x: 250.0, y: 250.0, rx: 245.0, ry: 100.0)
                .rasterize(x: xRange, y: yRange),
            color:
                .red
        )

        bitmap.swap(x1: 10, y1: 10, x2: width / 2, y2: height / 2)

        assertSnapshot(
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testReflectVertically() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
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
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testReflectHorizontally() {
        let width = 500, height = 500
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
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
            matching: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func fBitmap() -> Bitmap {
        let width = 60, height = 80
        let xRange = 0...width - 1, yRange = 0...height - 1
        var bitmap = Bitmap(width: width, height: height, color: .white)
        bitmap.draw(
            lines: Rectangle(strokeWidth: 1, x1: 10, y1: 10, x2: 50, y2: 20).rasterize(x: xRange, y: yRange),
            color: .black
        )
        bitmap.draw(
            lines: Rectangle(strokeWidth: 1, x1: 10, y1: 30, x2: 40, y2: 40).rasterize(x: xRange, y: yRange),
            color: .black
        )
        bitmap.draw(
            lines: Rectangle(strokeWidth: 1, x1: 10, y1: 10, x2: 20, y2: 70).rasterize(x: xRange, y: yRange),
            color: .black
        )
        return bitmap
    }

    func testRotateUp() {
        var f = fBitmap()
        f.rotateToUpOrientation(accordingTo: .up)
        assertSnapshot(
            matching: f,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testRotateUpMirrored() {
        var f = fBitmap()
        f.reflectVertically()
        f.rotateToUpOrientation(accordingTo: .upMirrored)
        assertSnapshot(
            matching: f,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testRotateDown() {
        var f = fBitmap()
        f.reflectVertically()
        f.reflectHorizontally()
        f.rotateToUpOrientation(accordingTo: .down)
        assertSnapshot(
            matching: f,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testRotateDownMirrored() {
        var f = fBitmap()
        f.reflectHorizontally()
        f.rotateToUpOrientation(accordingTo: .downMirrored)
        assertSnapshot(
            matching: f,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testRotateLeftMirrored() {
        var f = fBitmap()
        f.transpose()
        f.rotateToUpOrientation(accordingTo: .leftMirrored)
        assertSnapshot(
            matching: f,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    func testDraw() {
        var bitmap = Bitmap(width: 4, height: 5, color: .black)
        bitmap.draw(
            lines: [
                Scanline(y: 0, x1: 0, x2: 3),
                Scanline(y: 1, x1: 0, x2: 3),
                Scanline(y: 2, x1: 0, x2: 3),
                Scanline(y: 3, x1: 0, x2: 3),
                Scanline(y: 4, x1: 0, x2: 3)],
            color: .white
        )
        XCTAssertEqual(bitmap, Bitmap(width: 4, height: 5, color: .white))

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

    func testInitFromString() {
        XCTAssertEqual(
            Bitmap(
                stringLiteral:
                """
                width: 3, height: 2
                1,2,3,4,5,6,7,8,9,10,11,12,
                13,14,15,16,17,18,19,20,21,22,23,24
                """
            ),
            Bitmap(
                width: 3, height: 2,
                data: Array(1...24)
            )
        )
    }

    func testDescription() {
        XCTAssertEqual(
            Bitmap(
                width: 3, height: 2,
                data: Array(1...24)
            ).description,
            """
            width: 3, height: 2
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
            """
        )
    }

}
