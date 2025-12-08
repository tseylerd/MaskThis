import SwiftUI
import ServiceManagement
import OSLog

@MainActor
@Observable
class AppSettingsModel {
    private static nonisolated let LOG = Logger(subsystem: Subsystems.SETTINGS, category: "AppSettingsModel")
    
    var showNotification: Bool = AppSettings.shared.showNotification
    var enabled: Bool = AppSettings.shared.enabled
    
    private var _launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    
    var launchAtLogin: Bool {
        get {
            _launchAtLogin
        }
        set {
            if newValue {
                enableAutoLaunch()
            } else {
                disableAutoLaunch()
            }
        }
    }
    
    private func enableAutoLaunch() {
        do {
            try SMAppService.mainApp.register()
            _launchAtLogin = true
        } catch {
            Self.LOG.error("Failed to enable launch at login: \(error.localizedDescription)")
        }
    }
    
    private func disableAutoLaunch() {
        do {
            try SMAppService.mainApp.unregister()
            _launchAtLogin = false
        } catch {
            Self.LOG.error("Failed to disable launch at login: \(error.localizedDescription)")
        }
    }
}
