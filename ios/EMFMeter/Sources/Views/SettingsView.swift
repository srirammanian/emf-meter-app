import SwiftUI

/// Settings view for configuring the EMF Meter.
struct SettingsView: View {
    let selectedUnit: EMFUnit
    let selectedTheme: String
    let onUnitChange: (EMFUnit) -> Void
    let onThemeChange: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

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

                // Disclaimer
                Section {
                    Text("This app is for educational and entertainment purposes only. It is not a certified EMF measurement device. Readings may vary based on device sensor quality and should not be used for safety decisions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Disclaimer")
                }

                // Version info
                Section {
                    HStack {
                        Spacer()
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(
        selectedUnit: .milliGauss,
        selectedTheme: "system",
        onUnitChange: { _ in },
        onThemeChange: { _ in }
    )
}
