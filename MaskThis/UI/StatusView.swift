import SwiftUI
import FoundationModels

struct StatusView: View {
    @Environment(AppModel.self) var model
    @Environment(AppSettingsModel.self) var settings
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        VStack {
            if case .processing = model.appStatus {
                ProcessingStatusView()
            } else if case .unavailable(let reason) = model.aiStatus {
                AIErrorView(reason: reason)
            } else if !model.modelState.isReady {
                AdapterStateView(state: model.modelState)
            } else if settings.enabled {
                ReadyView()
            } else {
                DisabledView()
            }
        }
    }
}
