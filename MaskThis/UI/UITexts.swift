nonisolated struct UITexts {
    private init() { }
    
    struct Notifications {
        private init() { }
        
        static let successfullyMasked = "Sensitive Data Hidden"
        static let error = "Masking Failed"
    }
    
    struct Actions {
        private init() { }
        
        static let quit = "Quit"
    }
    
    struct Toggles {
        private init() { }
        
        static let enabled = "Enabled"
        static let showNotifications = "Show notifications"
        static let launchAtLogin = "Launch at login"
    }
    
    struct Statuses {
        private init() { }
        
        static let readyStatus = "Ready"
        static let disabledStatus = "Disabled"
        static let progressStatus = "Processing..."
        static let settingUp = "Setting up..."
        
        struct Errors {
            private init() { }
            
            static let appleIntelligenceNotEnabled = "Apple Intelligence not enabled"
            static let appleIntelligenceNotSupported = "Apple Intelligence is not supported by this device"
            static let appleIntelligenceLoading = "Setting up Apple Intelligence"
            
            static let lastError = "Last error"
            static let installationFailed = "Model installation failed"
            
            static let tooBigText = "The text is too big to be masked."
        }
        
        struct ModelState {
            private init() { }
            
            static let paused = "Model download paused"
            
            static func progress(_ fraction: Double) -> String {
                return "Downloading model: \(fraction)"
            }
        }
    }
}
