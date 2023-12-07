<p align="center" style="padding-bottom:50px;">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-5.x-orange.svg?style=flat"/></a> 
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg"/></a> 
<a href="https://github.com/valeriyvan/swift-geometrize"><img src="https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey"/></a> 
<a href="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-macos.yml"><img src="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-macos.yml/badge.svg"/></a>
<a href="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-ubuntu.yml"><img src="https://github.com/valeriyvan/swift-geometrize/actions/workflows/build-run-tests-ubuntu.yml/badge.svg"/></a>
</p>

![Geometrize logo fulltext](https://github.com/valeriyvan/swift-geometrize/assets/1630974/57fec4a6-39f0-41c2-9220-0838b3a0f2c3)

## swift-geometrize

Swift package for recreating images as geometric primitives. It began as a Swift port of the [geometrize-lib C++ library](https://github.com/Tw1ddle/geometrize-lib), but it has since evolved in a distinct direction.

## Usage

Look [`geometrize-cli` target](https://github.com/valeriyvan/swift-geometrize/blob/main/Sources/geometrize-cli/main.swift) how package could be used to geometrize images.

## Shape Comparison

The matrix below shows typical results for a combination of circles, triangles, rotated rectangles, rotated ellipses and all supported shapes at 50, 200 and 500 total shapes:

|                    | 50 Shapes     | 200 Shapes    | 500 Shapes   |
| ------------------ | ------------- | ------------- | ------------ |
| Circles            | ![Chicken 50 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/a6be73e5-a050-48db-9aa5-3e1bd89e262a) | ![Chicken 200 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/d8c91920-20d4-4f20-8690-87b04bb57547) | ![Chicken 500 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/92d80ea7-1f32-4479-a4c6-dc9ea7f542f1) |
| Triangles          |![Chicken 50 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/9f86e1e7-baf2-47dd-95e9-d4edcbb6cb9a) | ![Chicken 200 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/5db19159-00a5-4e39-ba62-969e7832a021) | ![Chicken 500 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/951d6e79-e306-4693-972f-b0eccb76307b) |
| Rotated Rectangles | ![Chicken 50 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/24c2ce23-0c51-4c59-9114-097d8a245ad9) | ![Chicken 200 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/8b67deaa-7975-4df2-b508-4ae75977ed25) | ![Chicken 500 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/380b5422-60f7-467f-852d-47dc6dfd63e0) |
| Rotated Ellipses   | ![Chicken 50 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/2b9b9f3a-3c83-4c33-b17a-83361c377399) | ![Chicken 200 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/f66ead22-d77c-4d1c-a68b-1533e0225b07) |![Chicken 500 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/47043915-08e7-4939-9c65-d5962f8f1af9) |
| All Shapes         | ![Chicken 50 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/a92de12f-cc32-45e8-8e51-1738d67e3f67) | ![Chicken 200 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/59fc400b-1030-426c-8ed1-ce47dfaf6598) | ![Chicken 500 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/32f532a0-7281-44ef-a258-3fa95f060024) |

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
* [photo mosaic](https://en.wikipedia.org/wiki/Photographic_mosaic);
* [string art](https://en.wikipedia.org/wiki/String_art).

## License

Licensed under MIT license.

<a href="https://www.buymeacoffee.com/valeriyvan" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
