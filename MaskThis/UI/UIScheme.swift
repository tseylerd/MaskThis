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
    
    var feedbackImage: String {
        "envelope.fill"
    }
    
    var feedbackImageNoFill: String {
        "envelope"
    }
    
    var helpImage: String {
        "questionmark.circle"
    }
    
    var aboutImage: String {
        "info.circle"
    }
    
    var manualModeImage: String {
        "hand.raised"
    }
    
    var rateAppImage: String {
        "star.fill"
    }
    
    var privacyImage: String {
        "lock.shield"
    }
    
    var launchAtLoginImage: String {
        "bolt.circle"
    }
    
    var notificationsImage: String {
        "bell.badge"
    }
    
    var modesImage: String {
        "rectangle.and.hand.point.up.left.fill"
    }
    
    var runInBackgroundImage: String {
        "menubar.arrow.up.rectangle"
    }
    
    var howToUseImage: String {
        "book"
    }
    
    var generalSettingsImage: String {
        "gear"
    }
    
    var ossSettingsImage: String {
        "chevron.left.slash.chevron.right"
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
