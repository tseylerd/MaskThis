import SwiftUI

struct AdapterStateView: View {
    let state: ModelState
    
    var body: some View {
        switch state {
        case .paused:
            PausedView()
        case .prepare:
            PrepareView()
        case .error(let text):
            ModelAdapterErrorView(error: text)
        case .downloading(let fraction):
            ModelAdapterPorgressView(fraction: fraction)
        default:
            EmptyView()
        }
    }
}

fileprivate struct PausedView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.ModelState.paused, systemImage: scheme.pauseImage)
    }
}

fileprivate struct PrepareView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        Label(UITexts.Statuses.settingUp, systemImage: scheme.progressImage)
    }
}

fileprivate struct ModelAdapterErrorView: View {
    @Environment(UIScheme.self) var scheme
    
    let error: String
    
    var body: some View {
        VStack {
            Label(UITexts.Statuses.Errors.installationFailed, systemImage: scheme.errorImage)
            Text(error)
                .foregroundColor(scheme.errorTextColor)
        }
    }
}

fileprivate struct ModelAdapterPorgressView: View {
    @Environment(UIScheme.self) var scheme
    
    let fraction: Double
    
    var body: some View {
        Label(UITexts.Statuses.ModelState.progress(fraction), systemImage: scheme.progressImage)
    }
}
