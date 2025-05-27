import CollectionsBenchmark
import Geometrize
import Foundation

// run with `swift run -c release benchmark run results --min-size 10000 --max-size 10000000 --cycles 5`

var benchmark = Benchmark(title: "Bitmap.addFrame")
benchmark.registerInputGenerator(for: Bitmap.self) { size in
    let width = max(1, Int(Double(size).squareRoot() * Double.random(in: 0.0...0.5)))
    let height = size / width
    return Bitmap(width: width, height: height, color: .black)
}

benchmark.addSimple(
  title: "Bitmap.averageColor",
  input: Bitmap.self
) { input in
  blackHole(input.averageColor())
}

benchmark.add(
  title: "Bitmap.reflectVertically indirectly over rotateToUpOrientation",
  input: Bitmap.self
) { input in
    var copy = input
    return { timer in
        copy.rotateToUpOrientation(accordingTo: Bitmap.ExifOrientation.upMirrored)
    }
}

benchmark.main()
