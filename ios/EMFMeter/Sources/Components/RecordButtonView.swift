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
                    // Button housing (metallic rim)
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

                    // Inner depression/socket
                    Circle()
                        .fill(Color(hex: "1A1A1A"))
                        .frame(width: 42, height: 42)
                        .offset(y: isPressed ? 2 : 0)

                    // Red button surface with 3D effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: isRecording
                                    ? [.recordButtonRedBright, Color(hex: "AA0000")]
                                    : [.recordButtonRed, .recordButtonRedDark],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 18
                            )
                        )
                        .frame(width: 36, height: 36)
                        .offset(y: isPressed ? 3 : 0)
                        .shadow(
                            color: isRecording ? .recordButtonRedBright.opacity(0.5) : .black.opacity(0.4),
                            radius: isPressed ? 1 : 2,
                            y: isPressed ? 1 : 2
                        )

                    // Highlight on button top
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 36, height: 36)
                        .offset(y: isPressed ? 3 : 0)

                    // Recording indicator light (blinking dot)
                    if isRecording {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .offset(y: isPressed ? 3 : 0)
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
                            .frame(width: 36, height: 36)
                            .offset(y: isPressed ? 3 : 0)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(y: isPressed ? 3 : 0)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )

            // Label under button
            VStack(spacing: 2) {
                Text(isRecording ? "STOP" : "REC")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isRecording ? .recordButtonRedBright : .white.opacity(0.7))

                // Duration display when recording
                if let duration = duration, isRecording {
                    Text(duration)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.recordButtonRedBright)
                }
            }
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
