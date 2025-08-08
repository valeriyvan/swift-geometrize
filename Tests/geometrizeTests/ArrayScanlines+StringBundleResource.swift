import Foundation
import Geometrize

extension [Scanline] {

    init(stringBundleResource resource: String, withExtension extension: String) throws {
        guard let url = Bundle.module.url(forResource: resource, withExtension: `extension`) else {
            fatalError("Resource \"\(resource).\(`extension`)\" not found in bundle")
        }
        let scanlinesString = try String(contentsOf: url, encoding: .utf8)
        var components = scanlinesString.components(separatedBy: "),")
        for i in components.indices.dropLast() {
            components[i] += ")"
        }
        self = components.map(Scanline.init)
    }

}
