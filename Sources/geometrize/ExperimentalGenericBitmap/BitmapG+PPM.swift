import Foundation

// TODO: this should not rely on RGBAccessible, but for proof of concept this works well.
extension BitmapG where ColorType: RGBAccessible {
    @frozen public enum ParsePpmError: Error {
        case noP3
        case inconsistentHeader(String)
        case maxElementNot255(String)
        case wrongElement(String)
        case excessiveCharacters(String)
    }

    // Format is described in https://en.wikipedia.org/wiki/Netpbm and https://netpbm.sourceforge.net/doc/ppm.html
    public init(ppmString string: String) throws {
        var stringWithTrimmedComments = ""
        string.enumerateLines { line, _ in
            let endIndex = line.firstIndex(of: "#") ?? line.endIndex
            stringWithTrimmedComments.append(line[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines))
            stringWithTrimmedComments.append(" ")
        }
        let scanner = Scanner(string: stringWithTrimmedComments)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines
        guard scanner.scanString("P3") != nil else {
            throw ParsePpmError.noP3
        }
        guard let width = scanner.scanInt(), width > 0, let height = scanner.scanInt(), height > 0 else {
            throw ParsePpmError.inconsistentHeader(String(string[..<scanner.currentIndex]))
        }
        guard let maxValue = scanner.scanInt(), maxValue == 255
        else {
            throw ParsePpmError.maxElementNot255(String(string[..<scanner.currentIndex]))
        }
        
        self.width = width
        self.height = height
        let capacity = width * height * ColorType.totalSize
        self.backing = try ContiguousArray<UInt8>(unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
            var pixelIndex = 0
            repeat {
                let startIndex = scanner.currentIndex
                guard
                    let red = scanner.scanInt(), 0...255 ~= red,
                    let green = scanner.scanInt(), 0...255 ~= green,
                    let blue = scanner.scanInt(), 0...255 ~= blue
                else {
                    let context = String(string[startIndex..<scanner.currentIndex])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    throw ParsePpmError.wrongElement(context)
                }
                
                let color = ColorType(r: UInt8(red), g: UInt8(green), b: UInt8(blue))
                let offset = pixelIndex * ColorType.totalSize
                color.write(to: buffer, at: offset)
                pixelIndex += 1
                
            } while pixelIndex < width * height

            let startIndex = scanner.currentIndex
            guard scanner.isAtEnd else {
                let context = String(string[startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                throw ParsePpmError.excessiveCharacters(context)
            }
            initializedCount = capacity
        }
    }

    public func ppmString(background: ColorType = ColorType.white) -> String {
        """
        P3
        \(width) \(height)
        255

        """
        +
        (0..<height).flatMap { y in
            (0..<width).map { x in
                let color = self[x, y]
                let blended = color.blending(background: background)
                return "\(blended.r) \(blended.g) \(blended.b)"
            }
        }.joined(separator: "\n")
        + "\n"
    }

    public var ppmString: String { ppmString() }
}
