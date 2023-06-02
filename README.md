<p align="center" style="padding-bottom:50px;">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-5.x-orange.svg?style=flat"/></a> 
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg"/></a> 
<a href="https://github.com/valeriyvan/swift-geometrize"><img src="https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey"/></a> 
</p>

## Swift package for recreating images as geometric primitives. Swift port of geometrize C++ library.

## Shape Comparison

The matrix below shows typical results for a combination of circles, triangles, rotated rectangles, rotated ellipses and all supported shapes at 50, 200 and 500 total shapes:

| -                  | 50 Shapes     | 200 Shapes    | 500 Shapes   |
| ------------------ | ------------- | ------------- | ------------ |
| Circles            | ![Chicken 50 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/a6be73e5-a050-48db-9aa5-3e1bd89e262a) | ![Chicken 200 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/d8c91920-20d4-4f20-8690-87b04bb57547) | ![Chicken 500 Circles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/92d80ea7-1f32-4479-a4c6-dc9ea7f542f1) |
| Triangles          |![Chicken 50 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/9f86e1e7-baf2-47dd-95e9-d4edcbb6cb9a) | ![Chicken 200 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/5db19159-00a5-4e39-ba62-969e7832a021) | ![Chicken 500 Triangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/951d6e79-e306-4693-972f-b0eccb76307b) |
| Rotated Rectangles | ![Chicken 50 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/24c2ce23-0c51-4c59-9114-097d8a245ad9) | ![Chicken 200 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/8b67deaa-7975-4df2-b508-4ae75977ed25) | ![Chicken 500 RotatedRectangles](https://github.com/valeriyvan/swift-geometrize/assets/1630974/380b5422-60f7-467f-852d-47dc6dfd63e0) |
| Rotated Ellipses   | ![Chicken 50 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/2b9b9f3a-3c83-4c33-b17a-83361c377399) | ![Chicken 200 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/f66ead22-d77c-4d1c-a68b-1533e0225b07) |![Chicken 500 RotatedEllipses](https://github.com/valeriyvan/swift-geometrize/assets/1630974/47043915-08e7-4939-9c65-d5962f8f1af9) |
| All Shapes         | ![Chicken 50 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/a92de12f-cc32-45e8-8e51-1738d67e3f67) | ![Chicken 200 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/59fc400b-1030-426c-8ed1-ce47dfaf6598) | ![Chicken 500 All Shapes](https://github.com/valeriyvan/swift-geometrize/assets/1630974/32f532a0-7281-44ef-a258-3fa95f060024) |

## TODO:
* add stroke width for line, polyline and bezier curve;
* multithreading;
* solve dealing with randomness in tests.

<a href="https://www.buymeacoffee.com/valeriyvan" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## Original README:

[![Geometrize Logo](https://github.com/Tw1ddle/geometrize-lib/blob/master/screenshots/logo.png?raw=true "Geometrize logo")](https://www.geometrize.co.uk/)

[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/geometrize-lib/blob/master/LICENSE)
[![Build Status Badge](https://ci.appveyor.com/api/projects/status/github/Tw1ddle/geometrize-lib)](https://ci.appveyor.com/project/Tw1ddle/geometrize-lib)

[Geometrize](https://github.com/Tw1ddle/geometrize-lib) is a C++ library based on [primitive](https://github.com/fogleman/primitive). It recreates images as geometric primitives.

[![Geometrized Trees 210 Ellipses](https://github.com/Tw1ddle/geometrize-lib/blob/master/screenshots/tree_under_clouds.png?raw=true "Tree Under Clouds - 210 Ellipses")](https://www.geometrize.co.uk/)

## Features

 * Geometrize images into shapes.
 * Export the results as SVG, JSON and more.

## Usage

Refer to the minimal [example](https://github.com/Tw1ddle/geometrize-lib-example) project and read the [documentation](https://tw1ddle.github.io/geometrize-lib-docs/). These projects may also be useful references:

| Project                                                            |
|--------------------------------------------------------------------|
| [Geometrize App](https://github.com/Tw1ddle/geometrize)            |
| [Example](https://github.com/Tw1ddle/geometrize-lib-example)       |
| [Fuzz Tests](https://github.com/Tw1ddle/geometrize-lib-fuzzing)    |
| [Unit Tests](https://github.com/Tw1ddle/geometrize-lib-unit-tests) |
| [Documentation](https://github.com/Tw1ddle/geometrize-lib-docs)    |

See the [top level repo](https://github.com/Tw1ddle/geometrize-top-level-repo) for a listing of all the repositories included in the Geometrize project.

## Screenshots

See the [gallery](https://gallery.geometrize.co.uk/).

## Resources

See the Geometrize [resources](https://resources.geometrize.co.uk/) page.

## Notes
 * Got an idea or suggestion? Open an issue on GitHub, or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).
