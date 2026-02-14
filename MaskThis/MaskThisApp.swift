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
        clipboardManager = ClipboardManager(appModel, aiMonitor, settingsModel, notificationsManager)
        
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
                .onChange(of: settingsModel.showResultNotification) {
                    AppSettings.shared.showResultNotification = settingsModel.showResultNotification
                }.onChange(of: settingsModel.showResultNotification) {
                    AppSettings.shared.showProgressNotification = settingsModel.showProgressNotification
                }.onChange(of: settingsModel.auto) {
                    AppSettings.shared.auto = settingsModel.auto
                }
        }
        
        Settings {
            SettingsView()
                .environment(scheme)
                .environment(settingsModel)
        }
        
        Window(UITexts.Titles.howToUse, id: Constants.WindowID.howToUse) {
            HowToUseView()
                .environment(scheme)
                .scenePadding()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
