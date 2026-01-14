import SwiftUI

/// Main view for the EMF Meter app.
struct MainView: View {
    @StateObject private var viewModel = EMFViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()

            if !viewModel.sensorAvailable {
                SensorUnavailableView()
            } else {
                VStack(spacing: 0) {
                    // App title
                    Text("EMF Meter")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 16)

                    Spacer()

                    // Meter display (Analog or Digital)
                    Group {
                        if viewModel.displayMode == .analog {
                            VStack(spacing: 8) {
                                AnalogMeterView(
                                    needlePosition: viewModel.needlePosition,
                                    unit: viewModel.selectedUnit
                                )

                                // Current value display (only shown in analog mode)
                                Text("\(UnitConverter.formatValue(viewModel.displayValue, unit: viewModel.selectedUnit)) \(viewModel.selectedUnit.symbol)")
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(.appPrimary)
                            }
                            .transition(.opacity)
                        } else {
                            DigitalDisplayView(
                                value: viewModel.displayValue,
                                unit: viewModel.selectedUnit
                            )
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.displayMode)

                    Spacer()

                    // Mode toggle
                    ModeToggleView(currentMode: Binding(
                        get: { viewModel.displayMode },
                        set: { viewModel.setDisplayMode($0) }
                    ))
                    .padding(.bottom, 16)

                    // Control buttons
                    ControlButtonsView(
                        soundEnabled: viewModel.soundEnabled,
                        isCalibrated: viewModel.isCalibrated,
                        onSoundToggle: { viewModel.toggleSound() },
                        onCalibrate: { viewModel.calibrate() },
                        onSettingsClick: { viewModel.showSettings = true }
                    )
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(
                selectedUnit: viewModel.selectedUnit,
                selectedTheme: viewModel.theme,
                isCalibrated: viewModel.isCalibrated,
                onUnitChange: { viewModel.setUnit($0) },
                onThemeChange: { viewModel.setTheme($0) },
                onResetCalibration: { viewModel.resetCalibration() }
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .backgroundDark : .backgroundLight
    }
}

/// View shown when magnetometer is not available.
private struct SensorUnavailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("⚠️")
                .font(.system(size: 64))

            Text("Magnetometer not available on this device")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    MainView()
}
