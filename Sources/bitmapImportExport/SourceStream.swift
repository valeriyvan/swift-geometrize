import Foundation
import PNG
import JPEG

struct SourceStream: PNG.BytestreamSource, _JPEGBytestreamSource {

    private(set) var data: [UInt8] // TODO: use Data instead
    private(set) var position: Int
    private(set) var available: Int

    init(_ data: [UInt8]) {
        self.data = data
        self.position = data.startIndex
        self.available = data.startIndex
    }

    mutating func read(count: Int) -> [UInt8]? {
        guard position + count <= data.endIndex else { return nil }
        guard position + count < available else {
            available += 4096
            return nil
        }
        defer { position += count }
        return [UInt8](data[position ..< position + count])
    }

    mutating func reset(position: Int) {
        precondition(data.indices ~= position)
        self.position = position
    }

}
