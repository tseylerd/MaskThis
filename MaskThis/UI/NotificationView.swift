import SwiftUI

struct NotificationView: View {
    let data: NotificationData
    
    var backgroundColor: Color {
        switch data.type {
        case .info:
                .gray.opacity(0.1)
        case .error:
                .red.opacity(0.2)
        case .warining:
                .orange.opacity(0.2)
        }
    }
    
    var image: String {
        switch data.type {
        case .info:
                "eye.slash.fill"
        case .error:
                "xmark.octagon.fill"
        case .warining:
                "exclamationmark.triangle.fill"
        }
    }
    
    var titleWeight: Font.Weight {
        if let _ = data.subtitle {
            .regular
        } else {
            .light
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Label(data.title, systemImage: image)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .font(.title.weight(titleWeight))
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .font(.title.weight(.light))
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct NotificationData {
    let title: String
    let subtitle: String?
    let type: NotificationType
}

enum NotificationType {
    case info
    case warining
    case error
}
