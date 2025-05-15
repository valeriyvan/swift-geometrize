import Foundation
import PNG
import JPEG

struct SourceStream: PNG.BytestreamSource, _JPEGBytestreamSource {

    private(set) var data: Data
    private(set) var position: Int

    init(_ data: Data) {
        self.data = data
        self.position = data.startIndex
    }

    mutating func read(count: Int) -> [UInt8]? {
        guard position + count <= data.endIndex else { return nil }
        defer { position += count }
        return [UInt8](data[position ..< position + count])
    }

    mutating func reset(position: Int) {
        precondition(data.indices ~= position)
        self.position = position
    }

}
