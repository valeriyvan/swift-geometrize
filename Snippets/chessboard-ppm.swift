import Foundation
import Geometrize

// Create a 80x80 pixels bitmap with 8x8 chess board
let bitmap = Bitmap(width: 80, height: 80) { x, y in
    (x / 10 + y / 10) % 2 == 0 ? .black : .white
}

print(bitmap.ppmString())

// swift run chessboard-ppm > /tmp/chessboard.ppm && open /tmp/chessboard.ppm
