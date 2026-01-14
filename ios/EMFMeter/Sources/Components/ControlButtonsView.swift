import SwiftUI

/// Control buttons for sound toggle, calibration, and settings.
struct ControlButtonsView: View {
    let soundEnabled: Bool
    let isCalibrated: Bool
    let onSoundToggle: () -> Void
    let onCalibrate: () -> Void
    let onSettingsClick: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Sound toggle button
            Button(action: onSoundToggle) {
                HStack(spacing: 8) {
                    Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 16))
                    Text("Sound")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(soundEnabled ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(soundEnabled ? Color.appPrimary.opacity(0.8) : Color.secondary.opacity(0.2))
                )
            }
            .buttonStyle(.plain)

            // Calibrate button
            Button(action: onCalibrate) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                    Text("Calibrate")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isCalibrated ? Color.teal : Color.appPrimary)
                )
            }
            .buttonStyle(.plain)

            // Settings button
            Button(action: onSettingsClick) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 20) {
        ControlButtonsView(
            soundEnabled: true,
            isCalibrated: false,
            onSoundToggle: {},
            onCalibrate: {},
            onSettingsClick: {}
        )

        ControlButtonsView(
            soundEnabled: false,
            isCalibrated: true,
            onSoundToggle: {},
            onCalibrate: {},
            onSettingsClick: {}
        )
    }
    .padding()
}
