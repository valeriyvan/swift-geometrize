import XCTest
import Geometrize

extension Bitmap {

    init(ppmBundleResource resource: String, withExtension extension: String) throws {
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let string = try String(contentsOf: url)
        self = try Bitmap(ppmString: string)
    }

}
