import SwiftUI

/// Full-screen oscilloscope view with live data and session history.
/// Presented when Pro user taps on the oscilloscope in the main view.
struct FullScreenOscilloscopeView: View {
    let readings: [TimestampedReading]
    let maxValue: Float
    let unit: EMFUnit
    @ObservedObject var sessionStorage: SessionStorage

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSession: SessionMetadata?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Large oscilloscope header
                oscilloscopeHeader

                // Session history list
                sessionList
            }
            .navigationTitle("Oscilloscope")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedSession) { metadata in
                SessionDetailView(
                    sessionId: metadata.id,
                    sessionStorage: sessionStorage
                )
            }
        }
    }

    // MARK: - Computed Properties

    /// Current live reading value converted to selected unit
    private var currentValue: Float {
        guard let lastReading = readings.last else { return 0 }
        return UnitConverter.convert(lastReading.magnitude, from: .microTesla, to: unit)
    }

    /// Formatted current value string
    private var formattedCurrentValue: String {
        UnitConverter.formatValue(currentValue, unit: unit)
    }

    // MARK: - Oscilloscope Header

    private var oscilloscopeHeader: some View {
        VStack(spacing: 12) {
            // Live indicator and current reading
            HStack(alignment: .center) {
                // Live indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .shadow(color: .red.opacity(0.6), radius: 4)
                    Text("LIVE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                }

                Spacer()

                // Current reading display
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(formattedCurrentValue)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    Text(unit.symbol)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Large oscilloscope view - edge to edge
            OscilloscopeView(
                readings: readings,
                maxValue: maxValue,
                unit: unit,
                fullScreen: true
            )
            .frame(height: 300)
        }
    }

    // MARK: - Session List

    private var sessionList: some View {
        List {
            if sessionStorage.sessions.isEmpty {
                emptyStateView
            } else {
                sessionsSection
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "waveform.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("No Recordings")
                    .font(.headline)

                Text("Tap the REC button on the main screen to start recording EMF sessions.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }

    // MARK: - Sessions Section

    private var sessionsSection: some View {
        Section {
            ForEach(sessionStorage.sessions) { session in
                SessionRowView(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSession = session
                    }
            }
        } header: {
            Text("Recording History")
        }
    }
}

// MARK: - Session Row (duplicated for this view to keep it self-contained)

private struct SessionRowView: View {
    let session: SessionMetadata

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title and date
            HStack {
                Text(session.name ?? "Untitled Session")
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Date
            Text(dateFormatter.string(from: session.startTime))
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Stats row
            HStack(spacing: 16) {
                Label(durationFormatter.string(from: session.duration) ?? "--", systemImage: "clock")

                Label("\(session.readingCount)", systemImage: "waveform")

                Label(String(format: "%.1f", session.maxMagnitude), systemImage: "arrow.up")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    FullScreenOscilloscopeView(
        readings: [],
        maxValue: 200,
        unit: .microTesla,
        sessionStorage: SessionStorage()
    )
}
