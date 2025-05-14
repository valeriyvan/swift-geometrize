import XCTest
import SnapshotTesting
import Foundation
@testable import Geometrize

final class BitmapExporterTests: XCTestCase {

    func testExport() throws {
        let results: [ShapeResult] = [
            ShapeResult(
                score: 1.0,
                color: .red.withAlphaComponent(128),
                shape: Rectangle(strokeWidth: 1, x1: 10, y1: 10, x2: 90, y2: 90)
            ),
            ShapeResult(
                score: 1.0,
                color: .yellow.withAlphaComponent(128),
                shape: Triangle(strokeWidth: 1, x1: 50, y1: 0, x2: 100, y2: 100, x3: 0, y3: 100)
            )
        ]
        let exporter = BitmapExporter()
        let bitmap = exporter.export(data: results, width: 100, height: 100)
        assertSnapshot(
            of: bitmap,
            as: SimplySnapshotting(pathExtension: "png", diffing: Diffing<Bitmap>.image)
        )
    }

    // TODO: add test for images bigger than 500 pixels.
    // Iterators inside downsample image by default to max 500 pixels size.
    // Exporters are not aware of this therefore big geometrized images exported
    // into png/jpeg (may be svg as well) take only small part of image size.

}
