import SwiftUI

/// Vintage-styled recording button with depressed/pushable look.
struct RecordButtonView: View {
    let isRecording: Bool
    let isProUser: Bool
    let duration: String?
    let onTap: () -> Void
    let onUpgradeNeeded: () -> Void

    @State private var isPressed = false
    @State private var blinkOpacity: Double = 1.0

    var body: some View {
        VStack(spacing: 4) {
            Button(action: handleTap) {
                ZStack {
                    // Button housing (metallic rim) - stays fixed
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.recordButtonHousing, .recordButtonHousingDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 2)

                    // Inner depression/socket - stays fixed (the "hole" the button sits in)
                    Circle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(width: 42, height: 42)

                    // Red button surface with 3D effect - shrinks when pressed (like ZERO button)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: isRecording
                                    ? [.recordButtonRedBright, Color(hex: "AA0000")]
                                    : [.recordButtonRed, .recordButtonRedDark],
                                center: UnitPoint(x: 0.35, y: 0.35),
                                startRadius: 0,
                                endRadius: 16
                            )
                        )
                        .frame(width: isPressed ? 32 : 36, height: isPressed ? 32 : 36)
                        .shadow(
                            color: isRecording ? .recordButtonRedBright.opacity(0.5) : .black.opacity(0.4),
                            radius: isPressed ? 1 : 2,
                            x: 0,
                            y: isPressed ? 1 : 2
                        )

                    // Highlight on button top - matches button size
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 12
                            )
                        )
                        .frame(width: isPressed ? 30 : 34, height: isPressed ? 30 : 34)

                    // Recording indicator light (blinking dot)
                    if isRecording {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .opacity(blinkOpacity)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    blinkOpacity = 0.3
                                }
                            }
                            .onDisappear {
                                blinkOpacity = 1.0
                            }
                    }

                    // Lock icon for non-pro users
                    if !isProUser {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: isPressed ? 32 : 36, height: isPressed ? 32 : 36)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            }, perform: {})

            // Label under button - fixed height to prevent vertical movement
            VStack(spacing: 2) {
                Text(isRecording ? "STOP" : "REC")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isRecording ? .recordButtonRedBright : .white.opacity(0.7))

                // Duration display when recording (always reserve space)
                Text(isRecording && duration != nil ? duration! : " ")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.recordButtonRedBright)
                    .opacity(isRecording && duration != nil ? 1 : 0)
            }
            .frame(height: 28)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
        .accessibilityValue(isRecording ? "Recording in progress" : "")
        .accessibilityHint(isProUser ? "Double tap to \(isRecording ? "stop" : "start") recording" : "Requires Pro upgrade")
        .accessibilityAddTraits(.isButton)
    }

    private func handleTap() {
        if isProUser {
            onTap()
        } else {
            onUpgradeNeeded()
        }
    }
}

// MARK: - Preview

#Preview("Record Button - Idle") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordButtonView(
            isRecording: false,
            isProUser: true,
            duration: nil,
            onTap: {},
            onUpgradeNeeded: {}
        )
    }
}

#Preview("Record Button - Recording") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordButtonView(
            isRecording: true,
            isProUser: true,
            duration: "02:34",
            onTap: {},
            onUpgradeNeeded: {}
        )
    }
}

#Preview("Record Button - Locked") {
    ZStack {
        Color.black.ignoresSafeArea()
        RecordButtonView(
            isRecording: false,
            isProUser: false,
            duration: nil,
            onTap: {},
            onUpgradeNeeded: {}
        )
    }
}
