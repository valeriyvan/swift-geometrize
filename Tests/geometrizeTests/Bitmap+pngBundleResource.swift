import XCTest
import Geometrize
import BitmapImportExport

extension Bitmap {

    init(pngBundleResource resource: String, withExtension extension: String) throws {
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let data = try Data(contentsOf: url)
        self = try Bitmap(pngData: data)
    }

}
