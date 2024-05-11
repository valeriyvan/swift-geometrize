import Foundation

// Normally Int._random(in:using) just calls Int._random(in:using).
// Tests could change default implementation e.g. to read pre-generated random numbers from file.

// swiftlint:disable:next identifier_name
var _randomImplementationReference = _randomImplementation

// swiftlint:disable:next identifier_name
func _randomImplementation(in range: ClosedRange<Int>, using generator: inout SplitMix64) -> Int {
    Int.random(in: range, using: &generator)
}

extension Int {

    // swiftlint:disable:next identifier_name
    static func _random(in range: ClosedRange<Int>, using generator: inout SplitMix64) -> Int {
        _randomImplementationReference(range, &generator)
    }

}
