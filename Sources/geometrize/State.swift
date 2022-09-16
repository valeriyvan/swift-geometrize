import Foundation

struct State {
    
    // Creates a new state.
    // @param shape The shape.
    // @param alpha The color alpha of the geometric shape.
    init(shape: some Shape, alpha: UInt8) {
        self.score = -1
        self.alpha = alpha
        self.shape = shape
        self.shape.setup()
    }

    init(score: Double, alpha: UInt8, shape: some Shape) {
        self.score = score
        self.alpha = alpha
        self.shape = shape
    }
    
    func copy() -> State {
        State(score: score, alpha: alpha, shape: shape.copy())
    }
    
    // The score of the state, a measure of the improvement applying the state to the current bitmap will have.
    var score: Double
    
    // The alpha of the shape.
    var alpha: UInt8
    
    // The geometric primitive owned by the state.
    var shape: any Shape

     // Modifies the current state in a random fashion.
     // @return The old state, useful for undoing the mutation or keeping track of previous states.
    mutating func mutate() -> State {
        let oldState = copy()
        shape.mutate()
        score = -1
        return oldState
    }
    
}

extension State: Equatable {
    
    static func == (lhs: State, rhs: State) -> Bool {
        lhs.score == rhs.score && lhs.alpha == rhs.alpha && lhs.shape == rhs.shape
    }
    
}
