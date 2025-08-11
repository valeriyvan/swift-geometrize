import XCTest
import Geometrize

extension BitmapG<Rgba8888> {

    init(ppmBundleResource resource: String, withExtension extension: String) throws {
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let string = try String(contentsOf: url, encoding: .utf8)
        self = try BitmapG<Rgba8888>(ppmString: string)
    }

}
