import Foundation

public extension Array where Element == String {

    func shapeTypes() -> [Shape.Type?] {
        let allShapeTypeStrings = allShapeTypes.map { "\(type(of: $0))".dropLast(5).lowercased() } // /* drop .Type */
        return self.map {
            let needle = $0.lowercased().replacingOccurrences(of: "_", with: "")
            return allShapeTypeStrings.firstIndex(of: needle).flatMap { allShapeTypes[$0] }
        }
    }

}
