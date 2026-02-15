nonisolated struct UITexts {
    private init() { }
    
    struct Notifications {
        private init() { }
        
        static let maskingSensitiveInformation = "Masking sensitive information..."
        static let successfullyMasked = "Sensitive information masked"
        static let successfullyMaskedNote = "Masked by AI and may contain mistakes. Please double-check."
        static let nothingMasked = "No sensitive information found"
        static let error = "Masking failed"
    }
    
    struct Titles {
        private init() { }
        
        static let howToUse = "How to Use"
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
    
    struct HowToUse {
        private init() { }
        
        static let privacyTitle = "**Mask This** is private by design."
        static let privacyNote = "Masking is performed locally using Apple Foundation Model. Your data never leaves your Mac and is not collected."
        
        static let runsInBackgroundTitle = "The app runs in the background and is accessible via the Menu Bar."
        static let runsInBackgroundNote = "To close the app, select **Quit Mask This** in the menu."
        
        static let modesTitle = "Choose between Auto and Manual modes. Auto is active by default. Toggle **Mask Clipboard Automatically** to switch."
        static let modesNote = "In Auto mode, the app masks sensitive data in clipboard every time you copy. In Manual mode, use **Mask Clipboard Content** or press the shortcut (`Cmd+Shift+M` by default) to mask content in clipboard."
                
        static let notificationsTitle = "Stay informed with notifications whenever clipboard content is processing or masked."
        static let notificationsNote = "You can disable these notifications by switching off the **Show Progress Notifications** and **Show Result Notifications** toggles."
                
        static let launchAtLoginTitle = "Start **Mask This** automatically when you log in."
        static let launchAtLoginNote = "To enable this, simply turn on the **Launch at Login** toggle."
        
        static let feedbackTitle = "Feel free to reach out with any feedback."
    }
    
    struct Actions {
        private init() { }
        
        static let quit = "Quit Mask This"
        static let help = "Help"
        static let howToUse = "How to Use"
        static let mask = "Mask Clipboard Content"
        static let about = "About"
        static let ossUsed = "Open Source Software Used"
        static let contactUs = "Contact Us"
        static let rateApp = "Rate the App"
    }
    
    struct Toggles {
        private init() { }
        
        static let auto = "Mask Clipboard Automatically"
        static let autoDescription = "Sensitive information in the clipboard will be masked automatically"
        
        static let showProgressNotifications = "Show Progress Notifications"
        static let showResultNotifications = "Show Result Notifications"
        
        static let showProgressNotificationsDescription = "Show progress notifications when information is masking"
        static let showResultNotificationsDescription = "Show result notifications when information is masked"
        
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
            static let appleIntelligenceLoading = "Apple Intelligence is not ready"
            
            static let lastError = "Last error"
            static let installationFailed = "Model installation failed"
            
            static let tooBigText = "The text is too big to be masked."
        }
        
        struct ModelState {
            private init() { }
            
            static let paused = "Model installation paused"
            
            static func progress(_ fraction: Double) -> String {
                return "Installing model: \(fraction)"
            }
        }
    }
}
