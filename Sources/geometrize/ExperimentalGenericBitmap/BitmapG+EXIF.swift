import Foundation

extension BitmapG {
    // https://home.jeita.or.jp/tsc/std-pdf/CP3451C.pdf, page 30
    @frozen public enum ExifOrientation: Int {
        // 1 The 0th row is at the visual top of the image, and the 0th column is the visual left-hand side.
        case up = 1
        // 2 The 0th row is at the visual top of the image, and the 0th column is the visual right-hand side.
        case upMirrored = 2
        // 3 The 0th row is at the visual bottom of the image, and the 0th column is the visual right-hand side.
        case down = 3
        // 4 The 0th row is at the visual bottom of the image, and the 0th column is the visual left-hand side.
        case downMirrored = 4
        // 5 The 0th row is the visual left-hand side of the image, and the 0th column is the visual top.
        case leftMirrored = 5
        // 6 The 0th row is the visual right-hand side of the image, and the 0th column is the visual top.
        case left = 6
        // 7 The 0th row is the visual right-hand side of the image, and the 0th column is the visual bottom.
        case rightMirrored = 7
        // 8 The 0th row is the visual left-hand side of the image, and the 0th column is the visual bottom.
        case right = 8
    }

    public mutating func rotateToUpOrientation(accordingTo orientation: ExifOrientation) {
        switch orientation {
        case .up:
            ()
        case .upMirrored:
            reflectVertically()
        case .down:
            reflectDown()
        case .downMirrored:
            reflectHorizontally()
        case .leftMirrored:
            reflectLeftMirrored()
        case .left:
            reflectLeft()
        case .rightMirrored:
            reflectRightMirrored()
        case .right:
            reflectRight()
        }
    }

    private mutating func reflectDown() {
        guard width > 0 && height > 0 else { return }

        let totalPixels = pixelCount

        // We only need to process half of the pixels.
        // For odd dimensions, the center pixel stays in place.
        let pixelsToProcess = totalPixels / 2

        backing.withUnsafeMutableBufferPointer { buffer in
            for i in 0..<pixelsToProcess {
                let x1 = i % width
                let y1 = i / width
                let x2 = width - x1 - 1
                let y2 = height - y1 - 1

                let offset1 = (y1 * width + x1) * ColorType.totalSize
                let offset2 = (y2 * width + x2) * ColorType.totalSize

                // Swap all color components at once
                for j in 0..<ColorType.totalSize {
                    let temp = buffer[offset1 + j]
                    buffer[offset1 + j] = buffer[offset2 + j]
                    buffer[offset2 + j] = temp
                }
            }
        }
    }

    private mutating func reflectLeftMirrored() {
        guard width > 0 && height > 0 else { return }

        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: width * height * ColorType.totalSize) {
            buffer, initializedCapacity in
            backing.withUnsafeBufferPointer { source in
                for y in 0..<height {
                    for x in 0..<width {
                        let srcOffset = (y * width + x) * ColorType.totalSize
                        let destOffset = (x * height + y) * ColorType.totalSize
                        for i in 0..<ColorType.totalSize {
                            buffer[destOffset + i] = source[srcOffset + i]
                        }
                    }
                }
            }
            initializedCapacity = width * height * ColorType.totalSize
        }

        (width, height) = (height, width)
        backing = newBacking
    }

    private mutating func reflectLeft() {
        guard width > 0 && height > 0 else { return }

        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: width * height * ColorType.totalSize) {
            buffer, initializedCapacity in
            backing.withUnsafeBufferPointer { source in
                for y in 0..<height {
                    for x in 0..<width {
                        let srcOffset = (y * width + x) * ColorType.totalSize
                        let destOffset = (x * height + (height - y - 1)) * ColorType.totalSize
                        for i in 0..<ColorType.totalSize {
                            buffer[destOffset + i] = source[srcOffset + i]
                        }
                    }
                }
            }
            initializedCapacity = width * height * ColorType.totalSize
        }

        (width, height) = (height, width)
        backing = newBacking
    }

    private mutating func reflectRightMirrored() {
        guard width > 0 && height > 0 else { return }

        let newWidth = height
        let newHeight = width
        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: newWidth * newHeight * ColorType.totalSize) {
            buffer, initializedCapacity in
            backing.withUnsafeBufferPointer { source in
                for y in 0..<height {
                    for x in 0..<width {
                        let srcOffset = (y * width + x) * ColorType.totalSize
                        let newX = height - y - 1
                        let newY = width - x - 1
                        let destOffset = (newY * newWidth + newX) * ColorType.totalSize
                        for i in 0..<ColorType.totalSize {
                            buffer[destOffset + i] = source[srcOffset + i]
                        }
                    }
                }
            }
            initializedCapacity = newWidth * newHeight * ColorType.totalSize
        }

        (width, height) = (newWidth, newHeight)
        backing = newBacking
    }

    private mutating func reflectRight() {
        guard width > 0 && height > 0 else { return }

        let newWidth = height
        let newHeight = width
        let newBacking = ContiguousArray<UInt8>(unsafeUninitializedCapacity: newWidth * newHeight * ColorType.totalSize) {
            buffer, initializedCapacity in
            backing.withUnsafeBufferPointer { source in
                for y in 0..<height {
                    for x in 0..<width {
                        let srcOffset = (y * width + x) * ColorType.totalSize
                        let newX = y
                        let newY = width - 1 - x
                        let destOffset = (newY * newWidth + newX) * ColorType.totalSize
                        for i in 0..<ColorType.totalSize {
                            buffer[destOffset + i] = source[srcOffset + i]
                        }
                    }
                }
            }
            initializedCapacity = newWidth * newHeight * ColorType.totalSize
        }

        (width, height) = (newWidth, newHeight)
        backing = newBacking
    }
}