import Foundation

// https://github.com/ArminJo/Arduino-BlueDisplay/blob/master/src/LocalGUI/ThickLine.hpp

/**
 * Modified Bresenham draw(line) with optional overlap. Required for drawThickLine().
 * Overlap draws additional pixel when changing minor direction. For standard bresenham overlap, choose LINE_OVERLAP_NONE (0).
 *
 *  Sample line:
 *
 *    00+
 *     -0000+
 *         -0000+
 *             -00
 *
 *  0 pixels are drawn for normal line without any overlap LINE_OVERLAP_NONE
 *  + pixels are drawn if LINE_OVERLAP_MAJOR
 *  - pixels are drawn if LINE_OVERLAP_MINOR
 */

/**
 * Draws a line from aXStart/aYStart to aXEnd/aYEnd including both ends
 * @param aOverlap One of LINE_OVERLAP_NONE, LINE_OVERLAP_MAJOR, LINE_OVERLAP_MINOR, LINE_OVERLAP_BOTH
 */

enum LineOverlap {
    case none
    case major
    case minor
    case both
}

// swiftlint:disable:next cyclomatic_complexity function_body_length
func drawLineOverlap<N: SignedInteger>(from: Point<N>, to: Point<N>, aOverlap: LineOverlap) -> [Point<N>] {
    var aXStart = from.x
    var aYStart = from.y
    let aXEnd = to.x
    let aYEnd = to.y

    var tDeltaX: N, tDeltaY: N, tDeltaXTimes2: N, tDeltaYTimes2: N, tError: N, tStepX: N, tStepY: N

    if false /* ((aXStart == aXEnd) || (aYStart == aYEnd)) */ {
        // horizontal or vertical line -> fillRect() is faster than drawLine()
        //fillRect(aXStart, aYStart, aXEnd, aYEnd, aColor); // you can remove the check and this line if you have no fillRect() or drawLine() available.
    } else {
        var points: [Point<N>] = []

        // calculate direction
        tDeltaX = aXEnd - aXStart
        tDeltaY = aYEnd - aYStart
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
        points.append(Point(x: aXStart, y: aYStart))
        if tDeltaX > tDeltaY {
            // start value represents a half step in Y direction
            tError = tDeltaYTimes2 - tDeltaX
            while aXStart != aXEnd {
                // step in main direction
                aXStart += tStepX
                if tError >= 0 {
                    if aOverlap == .major {
                        // draw pixel in main direction before changing
                        points.append(Point(x: aXStart, y: aYStart))
                    }
                    // change Y
                    aYStart += tStepY
                    if aOverlap == .minor {
                        // draw pixel in minor direction before changing
                        points.append(Point(x: aXStart - tStepX, y: aYStart))
                    }
                    tError -= tDeltaXTimes2
                }
                tError += tDeltaYTimes2
                points.append(Point(x: aXStart, y: aYStart))
            }
        } else {
            tError = tDeltaXTimes2 - tDeltaY
            while aYStart != aYEnd {
                aYStart += tStepY
                if tError >= 0 {
                    if aOverlap == .major {
                        // draw pixel in main direction before changing
                        points.append(Point(x: aXStart, y: aYStart))
                    }
                    aXStart += tStepX
                    if aOverlap == .minor {
                        // draw pixel in minor direction before changing
                        points.append(Point(x: aXStart, y: aYStart - tStepY))
                    }
                    tError -= tDeltaYTimes2
                }
                tError += tDeltaXTimes2
                points.append(Point(x: aXStart, y: aYStart))
            }
        }
        return points
    }
}

/**
 * Bresenham with thickness
 * No pixel missed and every pixel only drawn once!
 * The code is bigger and more complicated than drawThickLineSimple() but it tends to be faster, since drawing a pixel is often a slow operation.
 * aThicknessMode can be one of LINE_THICKNESS_MIDDLE, LINE_THICKNESS_DRAW_CLOCKWISE, LINE_THICKNESS_DRAW_COUNTERCLOCKWISE
 */

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
    var aXStart = from.x
    var aYStart = from.y
    var aXEnd = to.x
    var aYEnd = to.y

    var tDeltaX: N, tDeltaY: N, tDeltaXTimes2: N, tDeltaYTimes2: N, tError: N, tStepX: N, tStepY: N

    if thickness <= 1 {
        return drawLineOverlap(from: from, to: to, aOverlap: .none)
    }

    /**
     * For coordinate system with 0.0 top left
     * Swap X and Y delta and calculate clockwise (new delta X inverted)
     * or counterclockwise (new delta Y inverted) rectangular direction.
     * The right rectangular direction for LINE_OVERLAP_MAJOR toggles with each octant
     */
    tDeltaY = aXEnd - aXStart
    tDeltaX = aYEnd - aYStart
    // mirror 4 quadrants to one and adjust deltas and stepping direction
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
    // adjust for right direction of thickness from line origin
    var tDrawStartAdjustCount = thickness / 2
    if thicknessMode == .counterclockwise {
        tDrawStartAdjustCount = thickness - 1
    } else if thicknessMode == .clockwise {
        tDrawStartAdjustCount = 0
    }

    var points: [Point<N>] = []

    /*
     * Now tDelta* are positive and tStep* define the direction
     * tSwap is false if we mirrored only once
     */
    // which octant are we now
    if tDeltaX >= tDeltaY {
        // Octant 1, 3, 5, 7 (between 0 and 45, 90 and 135, ... degree)
        if tSwap {
            tDrawStartAdjustCount = (thickness - 1) - tDrawStartAdjustCount
            tStepY = -tStepY
        } else {
            tStepX = -tStepX
        }
        /*
         * Vector for draw direction of the starting points of lines is rectangular and counterclockwise to main line direction
         * Therefore no pixel will be missed if LINE_OVERLAP_MAJOR is used on change in minor rectangular direction
         */
        // adjust draw start point
        tError = tDeltaYTimes2 - tDeltaX
        for _ in stride(from: tDrawStartAdjustCount, to: 0, by: -1) {
            // change X (main direction here)
            aXStart -= tStepX
            aXEnd -= tStepX
            if tError >= 0 {
                // change Y
                aYStart -= tStepY
                aYEnd -= tStepY
                tError -= tDeltaXTimes2
            }
            tError += tDeltaYTimes2
        }
        // draw start line. We can alternatively use drawLineOverlap(aXStart, aYStart, aXEnd, aYEnd, LINE_OVERLAP_NONE, aColor) here.
        points.append(contentsOf: 
            drawLineOverlap(
                from: Point(x: aXStart, y: aYStart),
                to: Point(x: aXEnd, y: aYEnd),
                aOverlap: .none
            )
        )
        // draw aThickness number of lines
        tError = tDeltaYTimes2 - tDeltaX
        for _ in stride(from: thickness, to: 1, by: -1) {
            // change X (main direction here)
            aXStart += tStepX
            aXEnd += tStepX
            tOverlap = .none
            if tError >= 0 {
                // change Y
                aYStart += tStepY
                aYEnd += tStepY
                tError -= tDeltaXTimes2
                /*
                 * Change minor direction reverse to line (main) direction
                 * because of choosing the right (counter)clockwise draw vector
                 * Use LINE_OVERLAP_MAJOR to fill all pixel
                 *
                 * EXAMPLE:
                 * 1,2 = Pixel of first 2 lines
                 * 3 = Pixel of third line in normal line mode
                 * - = Pixel which will additionally be drawn in LINE_OVERLAP_MAJOR mode
                 *           33
                 *       3333-22
                 *   3333-222211
                 * 33-22221111
                 *  221111                     /\
                 *  11                          Main direction of start of lines draw vector
                 *  -> Line main direction
                 *  <- Minor direction of counterclockwise of start of lines draw vector
                 */
                tOverlap = .major
            }
            tError += tDeltaYTimes2
            points.append(contentsOf:
                drawLineOverlap(
                    from: Point(x: aXStart, y: aYStart),
                    to: Point(x: aXEnd, y: aYEnd),
                    aOverlap: tOverlap
                )
            )
        }
    } else {
        // the other octant 2, 4, 6, 8 (between 45 and 90, 135 and 180, ... degree)
        if tSwap {
            tStepX = -tStepX
        } else {
            tDrawStartAdjustCount = (thickness - 1) - tDrawStartAdjustCount
            tStepY = -tStepY
        }
        // adjust draw start point
        tError = tDeltaXTimes2 - tDeltaY
        for _ in stride(from: tDrawStartAdjustCount, to: 0, by: -1) {
            aYStart -= tStepY
            aYEnd -= tStepY
            if tError >= 0 {
                aXStart -= tStepX
                aXEnd -= tStepX
                tError -= tDeltaYTimes2
            }
            tError += tDeltaXTimes2
        }
        // draw start line
        points.append(contentsOf: 
            drawLineOverlap(
                from: Point(x: aXStart, y: aYStart),
                to: Point(x: aXEnd, y: aYEnd),
                aOverlap: .none
            )
        )
        // draw aThickness number of lines
        tError = tDeltaXTimes2 - tDeltaY
        for _ in stride(from: thickness, to: 1, by: -1) {
            aYStart += tStepY
            aYEnd += tStepY
            tOverlap = .none
            if tError >= 0 {
                aXStart += tStepX
                aXEnd += tStepX
                tError -= tDeltaYTimes2
                tOverlap = .major
            }
            tError += tDeltaXTimes2
            points.append(contentsOf: 
                drawLineOverlap(
                    from: Point(x: aXStart, y: aYStart),
                    to: Point(x: aXEnd, y: aYEnd),
                    aOverlap: tOverlap
                )
            )
        }
    }
    return points
}
