import SwiftUI

@MainActor
class AppSettings {
    static let shared = AppSettings()
    
    private init() { }
    
    @AppStorage("show.progress.notification") var showProgressNotification: Bool = true
    @AppStorage("show.result.notification") var showResultNotification: Bool = true
    @AppStorage("auto") var auto: Bool = true
}
