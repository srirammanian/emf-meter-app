import SwiftUI

/// View displaying list of recorded sessions.
struct SessionHistoryView: View {
    @ObservedObject var sessionStorage: SessionStorage
    @State private var selectedSession: SessionMetadata?
    @State private var showingDeleteConfirmation = false
    @State private var sessionToDelete: SessionMetadata?

    var body: some View {
        List {
            if sessionStorage.sessions.isEmpty {
                emptyStateView
            } else {
                sessionsSection
                storageSection
            }
        }
        .navigationTitle("Recording History")
        .sheet(item: $selectedSession) { metadata in
            SessionDetailView(
                sessionId: metadata.id,
                sessionStorage: sessionStorage
            )
        }
        .alert("Delete Session?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete {
                    deleteSession(session)
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
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

    // MARK: - Sessions List

    private var sessionsSection: some View {
        Section {
            ForEach(sessionStorage.sessions) { session in
                SessionRowView(session: session)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSession = session
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            sessionToDelete = session
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text("\(sessionStorage.sessions.count) Session\(sessionStorage.sessions.count == 1 ? "" : "s")")
        }
    }

    // MARK: - Storage Info

    private var storageSection: some View {
        Section {
            HStack {
                Text("Storage Used")
                Spacer()
                Text(sessionStorage.formattedStorageSize)
                    .foregroundColor(.secondary)
            }

            Button(role: .destructive) {
                deleteAllSessions()
            } label: {
                HStack {
                    Spacer()
                    Text("Delete All Sessions")
                    Spacer()
                }
            }
            .disabled(sessionStorage.sessions.isEmpty)
        } header: {
            Text("Storage")
        }
    }

    // MARK: - Actions

    private func deleteSession(_ session: SessionMetadata) {
        do {
            try sessionStorage.delete(sessionId: session.id)
        } catch {
            print("Failed to delete session: \(error)")
        }
        sessionToDelete = nil
    }

    private func deleteAllSessions() {
        do {
            try sessionStorage.deleteAll()
        } catch {
            print("Failed to delete all sessions: \(error)")
        }
    }
}

// MARK: - Session Row

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
    NavigationView {
        SessionHistoryView(sessionStorage: SessionStorage())
    }
}
