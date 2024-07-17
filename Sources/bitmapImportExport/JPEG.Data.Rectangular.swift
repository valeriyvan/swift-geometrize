import JPEG

extension JPEG.Data.Rectangular<JPEG.Common> {

    func exifOrientation() -> Int {
        for m in metadata {
            switch m {
            case .exif(let exif):
                if let orientationTag = exif[tag: 0x112] {
                    let orientation = orientationTag.box.endianness == .littleEndian
                        ? orientationTag.box.contents.0 : orientationTag.box.contents.1
                    return Int(orientation)
                }
            default:
                ()
            }
        }
        return 1
    }

}
