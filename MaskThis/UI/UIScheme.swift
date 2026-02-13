import SwiftUI

@MainActor
@Observable
class UIScheme {
    var errorTextColor: Color {
        .red
    }
    
    var readyImage: String {
        "checkmark.circle"
    }
    
    var progressImage: String {
        "circle.dashed"
    }
    
    var warningImage: String {
        "exclamationmark.triangle"
    }
    
    var noImage: String {
        "nosign"
    }
    
    var pauseImage: String {
        "pause"
    }
    
    var errorImage: String {
        "xmark.circle.fill"
    }
}
