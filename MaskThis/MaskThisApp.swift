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
    private let notificationsManager: CustomNotificationManager
    
    init() {
        appModel = AppModel()
        scheme = UIScheme()
        modelFactory = BGAssetsFactory(appModel: appModel)
        aiMonitor = AIMonitor(appModel, modelFactory)
        settingsModel = AppSettingsModel()
        notificationsManager = CustomNotificationManager(appSettingsModel: settingsModel, scheme: scheme)
        clipboardManager = ClipboardManager(appModel, aiMonitor, notificationsManager)
        
        clipboardManager.subscribeOnChanges()
        aiMonitor.setupAIMonitoring()
    }
    
    var body: some Scene {
        MenuBarExtra("Mask This", systemImage: "eye.slash.fill") {
            MenuView()
                .environment(appModel)
                .environment(settingsModel)
                .environment(scheme)
                .environment(clipboardManager)
                .onChange(of: settingsModel.showNotification) {
                    AppSettings.shared.showNotification = settingsModel.showNotification
                } .onChange(of: settingsModel.auto) {
                    AppSettings.shared.auto = settingsModel.auto
                }
        }
        
        Settings {
            SettingsView()
                .environment(scheme)
                .environment(settingsModel)
        }
    }
}
