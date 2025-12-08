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
    var body: some View {
        Text(UITexts.Statuses.ModelState.paused)
    }
}

fileprivate struct PrepareView: View {
    var body: some View {
        Text(UITexts.Statuses.settingUp)
    }
}

fileprivate struct ModelAdapterErrorView: View {
    @Environment(UIScheme.self) var scheme
    
    let error: String
    
    var body: some View {
        VStack {
            Text(UITexts.Statuses.Errors.installationFailed)
                .foregroundColor(scheme.errorTextColor)
            Text(error)
                .foregroundColor(scheme.errorTextColor)
        }
    }
}

fileprivate struct ModelAdapterPorgressView: View {
    @Environment(UIScheme.self) var scheme
    
    let fraction: Double
    
    var body: some View {
        Text(UITexts.Statuses.ModelState.progress(fraction))
    }
}
