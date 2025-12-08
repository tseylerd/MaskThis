import SwiftUI

struct LastErrorView: View {
    private static nonisolated let MAX_SYMBOLS = 60
    
    @Environment(AppModel.self) var appModel
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        if let error = appModel.lastError {
            VStack {
                Text(UITexts.Statuses.Errors.lastError)
                Text(error.prefix(Self.MAX_SYMBOLS))
                    .foregroundColor(scheme.errorTextColor)
            }
        }
    }
}
