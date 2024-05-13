import Foundation

struct State {

    /// Creates a new state.
    /// - Parameters:
    ///   - shape: The shape.
    ///   - alpha: The color alpha of the geometric shape.
    init(shape: some Shape, alpha: UInt8) {
        self.score = -1
        self.alpha = alpha
        self.shape = shape
    }

    init(score: Double, alpha: UInt8, shape: some Shape) {
        self.score = score
        self.alpha = alpha
        self.shape = shape
    }

    func copy() -> State {
        State(score: score, alpha: alpha, shape: shape.copy())
    }

    /// The score of the state, a measure of the improvement applying the state to the current bitmap will have.
    var score: Double // TODO: what is valid range of the score?

    /// The alpha of the shape.
    var alpha: UInt8

    /// The geometric primitive owned by the state.
    var shape: any Shape

    ///  Modifies the current state in a random fashion.
    /// - Returns: The old state, useful for undoing the mutation or keeping track of previous states.
    mutating func mutate(
        x xRange: ClosedRange<Int>, // TODO: rename
        y yRange: ClosedRange<Int>, // TODO: rename
        using generator: inout SplitMix64
    ) -> State {
        let oldState = copy()
        shape.mutate(x: xRange, y: yRange, using: &generator)
        score = -1
        return oldState
    }

}
