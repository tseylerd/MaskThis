import SwiftUI

@MainActor
@Observable
class UIScheme {
    var errorTextColor: Color {
        .red
    }
    
    var autoModeImage: String {
        "sparkles"
    }
    
    var manualModeImage: String {
        "hand.raised"
    }
    
    var eyeDisabledImage: String {
        "eye.slash.fill"
    }
    
    var eyeEnabledImage: String {
        "eye.fill"
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
