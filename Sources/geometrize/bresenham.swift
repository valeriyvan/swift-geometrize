import Foundation

func bresenham<N: SignedInteger>(from: Point<N>, to: Point<N>) -> [Point<N>] {
    var dx = to.x - from.x
    let ix: N = (dx > 0 ? 1 : 0) - (dx < 0 ? 1 : 0)
    dx = abs(dx) << 1
    var dy = to.y - from.y
    let iy: N = (dy > 0 ? 1 : 0) - (dy < 0 ? 1 : 0)
    dy = abs(dy) << 1
    var points: [Point<N>] = [from]
    var from = from
    if dx >= dy {
        var error = dy - (dx >> 1)
        while from.x != to.x {
            if error >= 0 && (error != 0 || ix > 0) {
                error -= dx;
                from.y += iy
            }

            error += dy
            from.x += ix
            
            points.append(from)
        }
    } else {
        var error = dx - (dy >> 1)
        while from.y != to.y {
            if error >= 0 && (error != 0 || (iy > 0)) {
                error -= dy
                from.x += ix
            }

            error += dx
            from.y += iy

            points.append(from)
        }
    }
    return points
}
