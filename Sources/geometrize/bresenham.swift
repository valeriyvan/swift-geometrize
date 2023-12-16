import Foundation

// https://github.com/ArminJo/Arduino-BlueDisplay/blob/master/src/LocalGUI/ThickLine.hpp

// Modified Bresenham draw(line) with optional overlap. Required for drawThickLine().
// Overlap draws additional pixel when changing minor direction.
// For standard bresenham overlap, choose LineOverlap.none.
//
// Sample line:
//
//   00+
//    -0000+
//        -0000+
//            -00
//
// 0 pixels are drawn for normal line without any overlap LineOverlap.none
// + pixels are drawn if .major
// - pixels are drawn if .minor

// Draws a line including both ends.

enum LineOverlap {
    case none
    case major
    case minor
    // case both
}

// swiftlint:disable:next cyclomatic_complexity function_body_length
func drawLineOverlap<N: SignedInteger>(from: Point<N>, to: Point<N>, overlap: LineOverlap) -> [Point<N>] {
    var startX = from.x
    var startY = from.y
    let endX = to.x
    let endY = to.y

    //guard startX != endX && startY != endY else {
    //    // horizontal or vertical line -> fillRect() is faster than drawLine()
    //    return fillRect(startX, startY, endX, endY)
    //}
    
    var tDeltaX: N, tDeltaY: N, tDeltaXTimes2: N, tDeltaYTimes2: N, tError: N, tStepX: N, tStepY: N

    var points: [Point<N>] = []

    // calculate direction
    tDeltaX = endX - startX
    tDeltaY = endY - startY
    if tDeltaX < 0 {
        tDeltaX = -tDeltaX
        tStepX = -1
    } else {
        tStepX = 1
    }
    if tDeltaY < 0 {
        tDeltaY = -tDeltaY
        tStepY = -1
    } else {
        tStepY = 1
    }
    tDeltaXTimes2 = tDeltaX << 1
    tDeltaYTimes2 = tDeltaY << 1
    // draw start pixel
    points.append(Point(x: startX, y: startY))
    if tDeltaX > tDeltaY {
        // start value represents a half step in Y direction
        tError = tDeltaYTimes2 - tDeltaX
        while startX != endX {
            // step in main direction
            startX += tStepX
            if tError >= 0 {
                if overlap == .major {
                    // draw pixel in main direction before changing
                    points.append(Point(x: startX, y: startY))
                }
                // change Y
                startY += tStepY
                if overlap == .minor {
                    // draw pixel in minor direction before changing
                    points.append(Point(x: startX - tStepX, y: startY))
                }
                tError -= tDeltaXTimes2
            }
            tError += tDeltaYTimes2
            points.append(Point(x: startX, y: startY))
        }
    } else {
        tError = tDeltaXTimes2 - tDeltaY
        while startY != endY {
            startY += tStepY
            if tError >= 0 {
                if overlap == .major {
                    // draw pixel in main direction before changing
                    points.append(Point(x: startX, y: startY))
                }
                startX += tStepX
                if overlap == .minor {
                    // draw pixel in minor direction before changing
                    points.append(Point(x: startX, y: startY - tStepY))
                }
                tError -= tDeltaYTimes2
            }
            tError += tDeltaXTimes2
            points.append(Point(x: startX, y: startY))
        }
    }
    return points
}

// Bresenham with thickness.
// No pixel missed and every pixel only drawn once!
// The code is bigger and more complicated than drawThickLineSimple() but it tends to be faster,
// since drawing a pixel is often a slow operation.

enum ThicknessMode {
    case middle
    case clockwise
    case counterclockwise
}

// swiftlint:disable:next cyclomatic_complexity function_body_length
func drawThickLine<N: SignedInteger>(
    from: Point<N>,
    to: Point<N>,
    thickness: N = 1,
    thicknessMode: ThicknessMode = .middle
) -> [Point<N>] {
    var startX = from.x
    var startY = from.y
    var endX = to.x
    var endY = to.y

    var tDeltaX: N, tDeltaY: N, tDeltaXTimes2: N, tDeltaYTimes2: N, tError: N, tStepX: N, tStepY: N

    guard thickness > 1 else {
        return drawLineOverlap(from: from, to: to, overlap: .none)
    }

    // For coordinate system with 0.0 top left
    // Swap X and Y delta and calculate clockwise (new delta X inverted)
    // or counterclockwise (new delta Y inverted) rectangular direction.
    // The right rectangular direction for LINE_OVERLAP_MAJOR toggles with each octant
    tDeltaY = endX - startX
    tDeltaX = endY - startY
    // Mirror 4 quadrants to one and adjust deltas and stepping direction.
    var tSwap = true // count effective mirroring
    if tDeltaX < 0 {
        tDeltaX = -tDeltaX
        tStepX = -1
        tSwap = !tSwap
    } else {
        tStepX = +1
    }
    if tDeltaY < 0 {
        tDeltaY = -tDeltaY
        tStepY = -1
        tSwap = !tSwap
    } else {
        tStepY = +1
    }
    tDeltaXTimes2 = tDeltaX << 1
    tDeltaYTimes2 = tDeltaY << 1
    var tOverlap: LineOverlap
    // Adjust for right direction of thickness from line origin.
    var tDrawStartAdjustCount = thickness / 2
    if thicknessMode == .counterclockwise {
        tDrawStartAdjustCount = thickness - 1
    } else if thicknessMode == .clockwise {
        tDrawStartAdjustCount = 0
    }

    var points: [Point<N>] = []

    // Now tDelta* are positive and tStep* define the direction
    // tSwap is false if we mirrored only once

    // Which octant are we now
    if tDeltaX >= tDeltaY {
        // Octant 1, 3, 5, 7 (between 0 and 45, 90 and 135, ... degree)
        if tSwap {
            tDrawStartAdjustCount = (thickness - 1) - tDrawStartAdjustCount
            tStepY = -tStepY
        } else {
            tStepX = -tStepX
        }

        // Vector for draw direction of the starting points of lines is rectangular and 
        // counterclockwise to main line direction.
        // Therefore no pixel will be missed if LineOverlap.none is used on change in minor rectangular direction.

        // Adjust draw start point
        tError = tDeltaYTimes2 - tDeltaX
        for _ in stride(from: tDrawStartAdjustCount, to: 0, by: -1) {
            // Change X (main direction here)
            startX -= tStepX
            endX -= tStepX
            if tError >= 0 {
                // change Y
                startY -= tStepY
                endY -= tStepY
                tError -= tDeltaXTimes2
            }
            tError += tDeltaYTimes2
        }
        // Draw start line. 
        // We can alternatively use drawLineOverlap(startX, startY, endX, endY, LineOverlap.none, aColor) here.
        points.append(contentsOf:
            drawLineOverlap(
                from: Point(x: startX, y: startY),
                to: Point(x: endX, y: endY),
                overlap: .none
            )
        )
        // Draw thickness number of lines
        tError = tDeltaYTimes2 - tDeltaX
        for _ in stride(from: thickness, to: 1, by: -1) {
            // Change X (main direction here)
            startX += tStepX
            endX += tStepX
            tOverlap = .none
            if tError >= 0 {
                // Change Y
                startY += tStepY
                endY += tStepY
                tError -= tDeltaXTimes2
                //  Change minor direction reverse to line (main) direction
                //  because of choosing the right (counter)clockwise draw vector
                //  Use LINE_OVERLAP_MAJOR to fill all pixel
                //
                //  EXAMPLE:
                //  1,2 = Pixel of first 2 lines
                //  3 = Pixel of third line in normal line mode
                //  - = Pixel which will additionally be drawn in LINE_OVERLAP_MAJOR mode
                //            33
                //        3333-22
                //    3333-222211
                //  33-22221111
                //   221111                     /\
                //   11                          Main direction of start of lines draw vector
                //   -> Line main direction
                //   <- Minor direction of counterclockwise of start of lines draw vector
                tOverlap = .major
            }
            tError += tDeltaYTimes2
            points.append(contentsOf:
                drawLineOverlap(
                    from: Point(x: startX, y: startY),
                    to: Point(x: endX, y: endY),
                    overlap: tOverlap
                )
            )
        }
    } else {
        // The other octant 2, 4, 6, 8 (between 45 and 90, 135 and 180, ... degree).
        if tSwap {
            tStepX = -tStepX
        } else {
            tDrawStartAdjustCount = (thickness - 1) - tDrawStartAdjustCount
            tStepY = -tStepY
        }
        // Adjust draw start point.
        tError = tDeltaXTimes2 - tDeltaY
        for _ in stride(from: tDrawStartAdjustCount, to: 0, by: -1) {
            startY -= tStepY
            endY -= tStepY
            if tError >= 0 {
                startX -= tStepX
                endX -= tStepX
                tError -= tDeltaYTimes2
            }
            tError += tDeltaXTimes2
        }
        // Draw start line
        points.append(contentsOf:
            drawLineOverlap(
                from: Point(x: startX, y: startY),
                to: Point(x: endX, y: endY),
                overlap: .none
            )
        )
        // Draw thickness number of lines.
        tError = tDeltaXTimes2 - tDeltaY
        for _ in stride(from: thickness, to: 1, by: -1) {
            startY += tStepY
            endY += tStepY
            tOverlap = .none
            if tError >= 0 {
                startX += tStepX
                endX += tStepX
                tError -= tDeltaYTimes2
                tOverlap = .major
            }
            tError += tDeltaXTimes2
            points.append(contentsOf:
                drawLineOverlap(
                    from: Point(x: startX, y: startY),
                    to: Point(x: endX, y: endY),
                    overlap: tOverlap
                )
            )
        }
    }
    return points
}
