import Foundation
import Geometrize

// Define the cell size for the chessboard
let cellSize = 10

// Create a 80x80 pixels bitmap with 8x8 chess board
let bitmap = Bitmap(width: 80, height: 80) { x, y in
    (x / cellSize + y / cellSize) % 2 == 0 ? .black : .white
}

print(bitmap.ppmString())

// swift run chessboard-ppm > /tmp/chessboard.ppm && open /tmp/chessboard.ppm
