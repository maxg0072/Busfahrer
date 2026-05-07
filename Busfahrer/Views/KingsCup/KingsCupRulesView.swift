import SwiftUI

struct KingsCupRulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(Strings.kingsCup.rulesTitle)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(Theme.cardBgElevated)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 16)

                ScrollView {
                    Text(Strings.kingsCup.rulesText)
                        .font(Theme.calloutFont)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, Theme.sectionSpacing)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
