import SwiftUI

/// Settings view for configuring the EMF Meter.
struct SettingsView: View {
    let selectedUnit: EMFUnit
    let selectedTheme: String
    let isCalibrated: Bool
    let onUnitChange: (EMFUnit) -> Void
    let onThemeChange: (String) -> Void
    let onResetCalibration: () -> Void

    // Pro features
    @ObservedObject var storeManager: StoreKitManager
    @ObservedObject var sessionStorage: SessionStorage

    @Environment(\.dismiss) private var dismiss
    @State private var showUpgradePrompt = false
    @AppStorage("maxBackgroundDuration") private var maxBackgroundDuration: TimeInterval = RecordingConfig.defaultMaxBackgroundDuration

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationView {
            List {
                // Pro Status
                if !storeManager.isProUnlocked {
                    Section {
                        Button {
                            showUpgradePrompt = true
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Upgrade to Pro")
                                    .fontWeight(.semibold)
                                Spacer()
                                if let price = storeManager.proProduct?.displayPrice {
                                    Text(price)
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }

                // Pro Features - Recording History
                Section {
                    if storeManager.isProUnlocked {
                        NavigationLink {
                            SessionHistoryView(sessionStorage: sessionStorage)
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.blue)
                                Text("Recording History")
                                Spacer()
                                if !sessionStorage.sessions.isEmpty {
                                    Text("\(sessionStorage.sessions.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Button {
                            showUpgradePrompt = true
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(.secondary)
                                Text("Recording History")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Pro Features")
                }

                // Background Recording Duration (Pro only)
                if storeManager.isProUnlocked {
                    Section {
                        Picker("Max Duration", selection: $maxBackgroundDuration) {
                            Text("5 minutes").tag(TimeInterval(300))
                            Text("15 minutes").tag(TimeInterval(900))
                            Text("30 minutes").tag(TimeInterval(1800))
                            Text("1 hour").tag(TimeInterval(3600))
                            Text("2 hours").tag(TimeInterval(7200))
                            Text("3 hours").tag(TimeInterval(10800))
                        }
                    } header: {
                        Text("Background Recording")
                    } footer: {
                        Text("Maximum duration for recording when the app is in the background.")
                    }
                }

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

                // Purchases
                Section {
                    Button {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    } label: {
                        HStack {
                            Text("Restore Purchases")
                            Spacer()
                            if storeManager.purchaseState == .loading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(storeManager.purchaseState == .loading)
                } header: {
                    Text("Purchases")
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
                        VStack(spacing: 4) {
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if storeManager.isProUnlocked {
                                Text("Pro")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                            }
                        }
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
            .sheet(isPresented: $showUpgradePrompt) {
                UpgradePromptView(storeManager: storeManager)
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
        isCalibrated: true,
        onUnitChange: { _ in },
        onThemeChange: { _ in },
        onResetCalibration: {},
        storeManager: StoreKitManager(),
        sessionStorage: SessionStorage()
    )
}
