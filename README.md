<p align="center" style="padding-bottom:50px;">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-5.x-orange.svg?style=flat"/></a> 
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg"/></a> 
<a href="https://github.com/valeriyvan/swift-geometrize"><img src="https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey"/></a> 
<a href="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-macos.yml"><img src="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-macos.yml/badge.svg"/></a>
<a href="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-ubuntu.yml"><img src="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-ubuntu.yml/badge.svg"/></a>
</p>

![Geometrize logo fulltext](/images/geometrize-logo.svg)

## swift-geometrize

Swift package for recreating images using geometric primitives. It started as a Swift port of the [C++ library geometrize-lib](https://github.com/Tw1ddle/geometrize-lib), but has since evolved in its own direction. You can try it out in the [web version](https://geometrize.w7software.com).

## Usage

Look [`geometrize-cli` target](https://github.com/valeriyvan/swift-geometrize/blob/main/Sources/geometrize-cli/main.swift) how package could be used to geometrize images.

## Shape Comparison

The matrix below shows typical results for a combination of circles, triangles, rotated rectangles, rotated ellipses and all supported shapes at 50, 200 and 500 total shapes:

|                    | 50 Shapes     | 200 Shapes    | 500 Shapes   |
| ------------------ | ------------- | ------------- | ------------ |
| Circles            | ![Chicken 50 Circles](/images/chicken-circles-50.svg) | ![Chicken 200 Circles](/images/chicken-circles-200.svg) | ![Chicken 500 Circles](/images/chicken-circles-500.svg) |
| Triangles          |![Chicken 50 Triangles](/images/chicken-triangles-50.svg) | ![Chicken 200 Triangles](/images/chicken-triangles-200.svg) | ![Chicken 500 Triangles](/images/chicken-triangles-500.svg) |
| Rotated Rectangles | ![Chicken 50 RotatedRectangles](/images/chicken-rotated-rectangles-50.svg) | ![Chicken 200 RotatedRectangles](/images/chicken-rotated-rectangles-200.svg) | ![Chicken 500 RotatedRectangles](/images/chicken-rotated-rectangles-500.svg) |
| Rotated Ellipses   | ![Chicken 50 RotatedEllipses](/images/chicken-rotated-ellipses-50.svg) | ![Chicken 200 RotatedEllipses](/images/chicken-rotated-ellipses-200.svg) |![Chicken 500 RotatedEllipses](/images/chicken-rotated-ellipses-500.svg) |
| All Shapes         | ![Chicken 50 All Shapes](/images/chicken-all-shapes-50.svg) | ![Chicken 200 All Shapes](/images/chicken-all-shapes-200.svg) | ![Chicken 500 All Shapes](/images/chicken-all-shapes-500.svg) |

## Geometrizebot

You could try swift-geometrize in action in Telegram bot [Geometrizebot](https://t.me/geometrizebot) which is also written in Swift and [open-sourced](https://github.com/valeriyvan/geometrizebot).

## TODO:
* ✅ add stroke width for line, polyline and bezier curve;
* ✅ multithreading;
* add polygon as shape type;
* filling shapes with gradient;
* solve dealing with randomness in tests;
* geometrize with predefined or user supplied brush strokes;
* geometrize with characters (on output will be something which could be called ascii art or art produced by [James Cook Type Writer Artist](https://jamescookartwork.com));
* photo mosaic;
* [string art](https://en.wikipedia.org/wiki/String_art): [1](https://www.youtube.com/watch?v=WGccIFf6MF8), [2](https://www.youtube.com/watch?v=dBlSmg5T13M), [3](https://sites.google.com/view/virtuallypassed/home?authuser=0), [4](https://www.youtube.com/watch?v=M1gXuKFspgY);
* [tape art](https://www.tapeartacademy.com): [1](/images/Tape-that-1.jpeg), [2](/images/Tape-that-2.jpeg), [3](/images/Tape-that-3.jpeg), [4](/images/Tape-that-4.jpeg), [5](/images/Tape-that-5.jpeg), [6](https://www.tapethatcollective.com).

## License

Licensed under MIT license.

<a href="https://www.buymeacoffee.com/valeriyvan" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
