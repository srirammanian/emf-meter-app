import SwiftUI

/// Settings view for configuring the EMF Meter.
struct SettingsView: View {
    let selectedUnit: EMFUnit
    let selectedTheme: String
    let isCalibrated: Bool
    let onUnitChange: (EMFUnit) -> Void
    let onThemeChange: (String) -> Void
    let onResetCalibration: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Unit selection
                Section {
                    ForEach(EMFUnit.allCases) { unit in
                        OptionRow(
                            label: "\(unit.displayName) (\(unit.symbol))",
                            isSelected: selectedUnit == unit,
                            action: { onUnitChange(unit) }
                        )
                    }
                } header: {
                    Text("Unit")
                }

                // Theme selection
                Section {
                    OptionRow(
                        label: "System",
                        isSelected: selectedTheme == "system",
                        action: { onThemeChange("system") }
                    )
                    OptionRow(
                        label: "Light",
                        isSelected: selectedTheme == "light",
                        action: { onThemeChange("light") }
                    )
                    OptionRow(
                        label: "Dark",
                        isSelected: selectedTheme == "dark",
                        action: { onThemeChange("dark") }
                    )
                } header: {
                    Text("Theme")
                }

                // Calibration
                Section {
                    HStack {
                        Text(isCalibrated ? "Calibrated" : "Not calibrated")
                            .foregroundColor(isCalibrated ? .green : .secondary)

                        Spacer()

                        if isCalibrated {
                            Button("Reset") {
                                onResetCalibration()
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.bordered)
                        }
                    }
                } header: {
                    Text("Calibration")
                }

                // Disclaimer
                Section {
                    Text("This app is for educational and entertainment purposes only. It is not a certified EMF measurement device. Readings may vary based on device sensor quality and should not be used for safety decisions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Disclaimer")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Reusable option row with checkmark.
private struct OptionRow: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundColor(isSelected ? .appPrimary : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(
        selectedUnit: .milliGauss,
        selectedTheme: "system",
        isCalibrated: true,
        onUnitChange: { _ in },
        onThemeChange: { _ in },
        onResetCalibration: {}
    )
}
