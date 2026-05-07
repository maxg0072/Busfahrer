import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                    HStack {
                        Text(Strings.rules.title)
                            .font(Theme.titleFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 30, height: 30)
                                .background(Theme.cardBgElevated)
                                .clipShape(Circle())
                        }
                    }

                    ruleSection(
                        title: Strings.rules.phase1Title,
                        icon: "🃏",
                        text: Strings.rules.phase1Text
                    )

                    ruleSection(
                        title: Strings.rules.phase2Title,
                        icon: "🔺",
                        text: Strings.rules.phase2Text
                    )

                    ruleSection(
                        title: Strings.rules.phase3Title,
                        icon: "🚌",
                        text: Strings.rules.phase3Text
                    )
                }
                .padding(Theme.padding)
            }
        }
    }

    private func ruleSection(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
            }

            Text(text)
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(Theme.textSecondary))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}
