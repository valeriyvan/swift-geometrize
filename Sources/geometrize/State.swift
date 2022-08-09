import Foundation

struct State {
    
    // The score of the state, a measure of the improvement applying the state to the current bitmap will have.
    var m_score: Double
    
    // The alpha of the shape.
    var m_alpha: UInt8
    
    // The geometric primitive owned by the state.
    var m_shape: Shape

     // Modifies the current state in a random fashion.
     // @return The old state, useful for undoing the mutation or keeping track of previous states.
    mutating func mutate() -> State {
        return self
    }
    
}
