import SwiftUI

/// Detailed view for a single recording session with editing and export.
struct SessionDetailView: View {
    let sessionId: UUID
    @ObservedObject var sessionStorage: SessionStorage

    @Environment(\.dismiss) private var dismiss

    @State private var session: RecordingSession?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var editedName: String = ""
    @State private var editedNotes: String = ""
    @State private var isEditing = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?

    @AppStorage("selectedUnit") private var selectedUnitRaw: String = EMFUnit.default.rawValue
    private var selectedUnit: EMFUnit {
        EMFUnit(rawValue: selectedUnitRaw) ?? .milliGauss
    }

    private let exportService = ExportService()

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading session...")
                } else if let session = session {
                    sessionContent(session)
                } else if let error = errorMessage {
                    errorView(error)
                }
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if session != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button {
                                exportSession()
                            } label: {
                                Label("Export CSV", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                if let session = session {
                    editSheet(session)
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
        .onAppear {
            loadSession()
        }
    }

    // MARK: - Session Content

    private func sessionContent(_ session: RecordingSession) -> some View {
        List {
            // Info Section
            infoSection(session)

            // Statistics Section
            statisticsSection(session)

            // Oscilloscope Preview
            oscilloscopeSection(session)

            // Notes Section
            if let notes = session.notes, !notes.isEmpty {
                notesSection(notes)
            }
        }
    }

    // MARK: - Sections

    private func infoSection(_ session: RecordingSession) -> some View {
        Section("Session Info") {
            LabeledContent("Name", value: session.name ?? "Untitled")

            LabeledContent("Date", value: formatDate(session.startTime))

            LabeledContent("Duration", value: formatDuration(session.duration))

            LabeledContent("Readings", value: "\(session.readings.count)")
        }
    }

    private func statisticsSection(_ session: RecordingSession) -> some View {
        let stats = session.statistics
        let unit = selectedUnit

        return Section("Statistics (\(unit.symbol))") {
            LabeledContent("Minimum") {
                Text(formatValue(unit.fromMicroTesla(stats.minMagnitude)))
                    .monospacedDigit()
            }

            LabeledContent("Maximum") {
                Text(formatValue(unit.fromMicroTesla(stats.maxMagnitude)))
                    .monospacedDigit()
            }

            LabeledContent("Average") {
                Text(formatValue(unit.fromMicroTesla(stats.avgMagnitude)))
                    .monospacedDigit()
            }
        }
    }

    private func oscilloscopeSection(_ session: RecordingSession) -> some View {
        Section("Recording Preview") {
            OscilloscopeView(
                readings: session.readings,
                maxValue: MeterConfig.maxValueUT,
                isProUser: true,
                onUpgradeNeeded: {}
            )
            .frame(height: 100)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }

    private func notesSection(_ notes: String) -> some View {
        Section("Notes") {
            Text(notes)
                .font(.body)
        }
    }

    // MARK: - Edit Sheet

    private func editSheet(_ session: RecordingSession) -> some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("Session name", text: $editedName)
                }

                Section("Notes") {
                    TextEditor(text: $editedNotes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEdits()
                    }
                }
            }
            .onAppear {
                editedName = session.name ?? ""
                editedNotes = session.notes ?? ""
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Failed to Load Session")
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Actions

    private func loadSession() {
        isLoading = true
        do {
            session = try sessionStorage.load(sessionId: sessionId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func saveEdits() {
        guard var updatedSession = session else { return }

        updatedSession.name = editedName.isEmpty ? nil : editedName
        updatedSession.notes = editedNotes.isEmpty ? nil : editedNotes

        do {
            try sessionStorage.save(updatedSession)
            session = updatedSession
            isEditing = false
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    private func exportSession() {
        guard let session = session else { return }

        if let url = exportService.generateCSV(from: session, unit: selectedUnit) {
            exportURL = url
            showingExportSheet = true
        }
    }

    // MARK: - Formatters

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "--"
    }

    private func formatValue(_ value: Float) -> String {
        String(format: "%.2f", value)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    SessionDetailView(
        sessionId: UUID(),
        sessionStorage: SessionStorage()
    )
}
