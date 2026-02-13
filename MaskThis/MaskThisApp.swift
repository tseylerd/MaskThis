import SwiftUI
import OSLog

@main
struct MaskThisApp: App {
    private let clipboardManager: ClipboardManager
    private let aiMonitor: AIMonitor
    private let appModel: AppModel
    private let modelFactory: ModelFactory
    private let settingsModel: AppSettingsModel
    private let scheme: UIScheme
    
    init() {
        appModel = AppModel()
        modelFactory = LocalModelAdapterFactory()
        aiMonitor = AIMonitor(appModel, modelFactory)
        settingsModel = AppSettingsModel()
        clipboardManager = ClipboardManager(appModel, aiMonitor)
        scheme = UIScheme()
        
        clipboardManager.subscribeOnChanges()
        aiMonitor.setupAIMonitoring()
    }
    
    var body: some Scene {
        MenuBarExtra("Mask This", systemImage: "eye.slash.fill") {
            MenuView()
                .environment(appModel)
                .environment(settingsModel)
                .environment(scheme)
                .onChange(of: settingsModel.showNotification) {
                    AppSettings.shared.showNotification = settingsModel.showNotification
                } .onChange(of: settingsModel.enabled) {
                    AppSettings.shared.enabled = settingsModel.enabled
                }
        }
    }
}
