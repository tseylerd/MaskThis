import SwiftUI

struct HowToUseView: View {
    @Environment(UIScheme.self) var scheme
    
    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
            
            HStack {
                VStack(alignment: .leading, spacing: 18) {
                    SinglePoint(data: SinglePointData(
                        image: scheme.privacyImage,
                        title: UITexts.HowToUse.privacyTitle,
                        note: UITexts.HowToUse.privacyNote
                    ))
                    SinglePoint(data: SinglePointData(
                        image: scheme.runInBackgroundImage,
                        title: UITexts.HowToUse.runsInBackgroundTitle,
                        note: UITexts.HowToUse.runsInBackgroundNote
                    ))
                    SinglePoint(data: SinglePointData(
                        image: scheme.modesImage,
                        title: UITexts.HowToUse.modesTitle,
                        note: UITexts.HowToUse.modesNote
                    ))
                    SinglePoint(data: SinglePointData(
                        image: scheme.notificationsImage,
                        title: UITexts.HowToUse.notificationsTitle,
                        note: UITexts.HowToUse.notificationsNote
                    ))
                    SinglePoint(data: SinglePointData(
                        image: scheme.launchAtLoginImage,
                        title: UITexts.HowToUse.launchAtLoginTitle,
                        note: UITexts.HowToUse.launchAtLoginNote
                    ))
                    SinglePoint(data: SinglePointData(
                        image: scheme.feedbackImageNoFill,
                        title: UITexts.HowToUse.feedbackTitle,
                        note: nil
                    ))
                    ContactUsLink()
                }
                Spacer()
            }
            Spacer()
        }
    }
}

fileprivate struct SinglePoint: View {
    let data: SinglePointData
    
    var body: some View {
        VStack(alignment: .leading) {
            Label {
                Text((try? AttributedString(markdown: data.title)) ?? AttributedString(data.title))
            } icon: {
                Image(systemName: data.image)
            }
            .font(.title3)
            .multilineTextAlignment(.leading)
            
            if let note = data.note {
                Text((try? AttributedString(markdown: note)) ?? AttributedString(note))
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

fileprivate struct SinglePointData {
    let image: String
    let title: String
    let note: String?
}

