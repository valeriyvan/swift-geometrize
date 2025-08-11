import XCTest
import Geometrize
import BitmapImportExport

extension BitmapG<Rgba8888> {

    init(pngBundleResource resource: String, withExtension extension: String) throws {
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let data = try Data(contentsOf: url)
        self = try BitmapG<Rgba8888>(pngData: data)
    }

}
