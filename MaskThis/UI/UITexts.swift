nonisolated struct UITexts {
    private init() { }
    
    struct Notifications {
        private init() { }
        
        static let successfullyMasked = "Sensitive Data Hidden"
        static let error = "Masking Failed"
    }
    
    struct Settings {
        private init() { }
        
        struct General {
            private init() { }
            
            static let shortcut = "Global shortcut"
            static let shortcutDescription = "Global shortcut to mask sensitive information in the clipboard"
            
            static let tabName = "General"
        }
        
        struct OSS {
            private init() { }
            
            static let tabName = "OSS Software"
        }
    }
    
    struct Actions {
        private init() { }
        
        static let quit = "Quit Mask This"
        static let mask = "Mask Clipboard"
    }
    
    struct Toggles {
        private init() { }
        
        static let auto = "Mask Clipboard Automatically"
        static let showNotifications = "Show Notifications"
        static let launchAtLogin = "Launch at Login"
    }
    
    struct Statuses {
        private init() { }
        
        static let autoModeStatus = "Auto Mode"
        static let manualModeStatus = "Manual Mode"
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
