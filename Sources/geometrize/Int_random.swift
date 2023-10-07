import Foundation

var _randomImplementationReference = _randomImplementation // swiftlint:disable:this identifier_name

private func _randomImplementation(in range: ClosedRange<Int>, using generator: inout SplitMix64) -> Int {
    Int.random(in: range, using: &generator)
}

extension Int {

    // swiftlint:disable:next identifier_name
    static func _random(in range: ClosedRange<Int>, using generator: inout SplitMix64) -> Int {
        _randomImplementationReference(range, &generator)
    }

}
