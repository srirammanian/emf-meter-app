import SwiftUI

/// Toggle switch for switching between Analog and Digital display modes.
struct ModeToggleView: View {
    @Binding var currentMode: DisplayMode

    var body: some View {
        HStack(spacing: 0) {
            ModeOption(
                text: "Analog",
                isSelected: currentMode == .analog
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMode = .analog
                }
            }

            ModeOption(
                text: "Digital",
                isSelected: currentMode == .digital
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMode = .digital
                }
            }
        }
        .padding(4)
        .background(Color.secondary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

/// Individual mode option button.
private struct ModeOption: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 100)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var mode: DisplayMode = .analog

    ModeToggleView(currentMode: $mode)
        .padding()
}
