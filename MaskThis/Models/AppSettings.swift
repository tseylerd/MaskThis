import SwiftUI

@MainActor
class AppSettings {
    static let shared = AppSettings()
    
    private init() { }
    
    @AppStorage("show.notification") var showNotification: Bool = true
    @AppStorage("enabled") var enabled: Bool = true
}
