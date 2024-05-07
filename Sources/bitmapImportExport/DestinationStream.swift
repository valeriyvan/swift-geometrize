import Foundation
import PNG
import JPEG

struct DestinationStream: PNG.BytestreamDestination, JPEG.Bytestream.Destination {

    private(set) var data: [UInt8] = []

    mutating func write(_ buffer: [UInt8]) -> Void? {
        data.append(contentsOf: buffer)
    }

}
