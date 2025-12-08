import SwiftUI

@MainActor
@Observable
class UIScheme {
    var readyStatusColor: Color {
        .green
    }
    
    var disabledStatusColor: Color {
        .green
    }
    
    var errorTextColor: Color {
        .red
    }
}
