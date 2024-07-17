import Foundation

struct State: Sendable {

    init(score: Double, alpha: UInt8, shape: some Shape) {
        self.score = score
        self.alpha = alpha
        self.shape = shape
    }

    /// The score of the state, a measure of the improvement applying the state to the current bitmap will have.
    let score: Double // TODO: what is valid range of the score?

    /// The alpha of the shape.
    let alpha: UInt8

    /// The geometric primitive owned by the state.
    let shape: any Shape

    ///  Modifies the current state in a random fashion.
    /// - Returns: new mutated state.
    mutating func mutate(
        x xRange: ClosedRange<Int>, // TODO: rename
        y yRange: ClosedRange<Int>, // TODO: rename
        using generator: inout SplitMix64,
        score: ((any Shape) -> Double)
    ) -> State {
        let mutatedShape = shape.mutate(x: xRange, y: yRange, using: &generator)
        return State(score: score(mutatedShape), alpha: alpha, shape: mutatedShape)
    }

}
