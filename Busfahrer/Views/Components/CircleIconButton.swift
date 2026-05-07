import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    var size: CGFloat = 40
    var iconSize: CGFloat = 16
    var bgColor: Color = Theme.cardBg
    var fgOpacity: Double = 0.7
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.selection()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(.white.opacity(fgOpacity))
                .frame(width: size, height: size)
                .background(bgColor)
                .clipShape(Circle())
        }
    }
}
