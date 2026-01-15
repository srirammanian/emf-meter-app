import SwiftUI

/// Modal view shown when free users attempt to access Pro features.
struct UpgradePromptView: View {
    @ObservedObject var storeManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Feature list
                    featuresSection

                    Spacer(minLength: 20)

                    // Price and purchase button
                    purchaseSection
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Upgrade to Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: storeManager.isProUnlocked) { unlocked in
            if unlocked {
                dismiss()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Oscilloscope icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.oscilloscopeBackground, .oscilloscopeBackgroundEdge],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "waveform.path")
                    .font(.system(size: 36))
                    .foregroundColor(.oscilloscopeTrace)
            }

            Text("EMF Scope Pro")
                .font(.title.bold())

            Text("Unlock advanced recording & analysis features")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FeatureRow(
                icon: "record.circle",
                iconColor: .red,
                title: "Session Recording",
                description: "Record EMF readings with timestamps"
            )

            Divider().padding(.leading, 44)

            FeatureRow(
                icon: "waveform",
                iconColor: .oscilloscopeTrace,
                title: "Live Oscilloscope",
                description: "Vintage CRT-style real-time graph"
            )

            Divider().padding(.leading, 44)

            FeatureRow(
                icon: "clock.arrow.circlepath",
                iconColor: .blue,
                title: "Session History",
                description: "Browse and manage saved recordings"
            )

            Divider().padding(.leading, 44)

            FeatureRow(
                icon: "square.and.arrow.up",
                iconColor: .orange,
                title: "CSV Export",
                description: "Share data for analysis"
            )

            Divider().padding(.leading, 44)

            FeatureRow(
                icon: "moon.fill",
                iconColor: .purple,
                title: "Background Recording",
                description: "Record up to 3 hours in background"
            )
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Purchase Section

    private var purchaseSection: some View {
        VStack(spacing: 16) {
            // Price display
            if let product = storeManager.proProduct {
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("One-time purchase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if storeManager.purchaseState == .loading {
                ProgressView()
                    .frame(height: 50)
            } else {
                // Show mock price on simulator or when product unavailable
                #if targetEnvironment(simulator)
                VStack(spacing: 4) {
                    Text("$2.99")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("One-time purchase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                #endif
            }

            // Error message
            if let error = storeManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            // Purchase button
            Button(action: {
                Task {
                    await storeManager.purchase()
                }
            }) {
                HStack {
                    if storeManager.purchaseState == .purchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Upgrade to Pro")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            #if targetEnvironment(simulator)
            .disabled(storeManager.purchaseState == .purchasing)
            #else
            .disabled(storeManager.purchaseState == .purchasing || storeManager.proProduct == nil)
            #endif

            // Restore purchases
            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.footnote)
            .foregroundColor(.blue)

            // Terms text
            Text("Payment will be charged to your Apple ID account. No subscription required.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview {
    UpgradePromptView(storeManager: StoreKitManager())
}
