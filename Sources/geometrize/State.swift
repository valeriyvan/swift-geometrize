import Foundation

struct State {
    
    // Creates a new state.
    // @param shape The shape.
    // @param alpha The color alpha of the geometric shape.
    init(shape: Shape, alpha: UInt8) {
        m_score = -1
        m_alpha = alpha
        m_shape = shape
        m_shape.setup()
    }

    // The score of the state, a measure of the improvement applying the state to the current bitmap will have.
    var m_score: Double
    
    // The alpha of the shape.
    var m_alpha: UInt8
    
    // The geometric primitive owned by the state.
    var m_shape: Shape

     // Modifies the current state in a random fashion.
     // @return The old state, useful for undoing the mutation or keeping track of previous states.
    mutating func mutate() -> State {
        let oldState = self
        m_shape.mutate()
        m_score = -1
        return oldState
    }
    
}
