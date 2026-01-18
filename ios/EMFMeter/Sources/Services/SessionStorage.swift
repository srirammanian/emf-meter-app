import Foundation

/// Manages persistence of recording sessions to local storage.
class SessionStorage: ObservableObject {
    // MARK: - Published State
    @Published private(set) var sessions: [SessionMetadata] = []

    // MARK: - Private
    private let sessionsDirectory: URL
    private let metadataFile: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        sessionsDirectory = documentsPath.appendingPathComponent("EMFSessions", isDirectory: true)
        metadataFile = sessionsDirectory.appendingPathComponent("metadata.json")

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        createDirectoryIfNeeded()
        loadMetadata()
    }

    // MARK: - Public API

    /// Save a recording session to storage.
    func save(_ session: RecordingSession) throws {
        // Save full session data
        let sessionFile = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
        let data = try encoder.encode(session)
        try data.write(to: sessionFile, options: .atomic)

        // Update metadata list
        let metadata = SessionMetadata(from: session)

        // Remove existing entry if updating
        sessions.removeAll { $0.id == session.id }
        sessions.insert(metadata, at: 0)

        saveMetadata()
    }

    /// Load a full session by ID.
    func load(sessionId: UUID) throws -> RecordingSession {
        let sessionFile = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        let data = try Data(contentsOf: sessionFile)
        return try decoder.decode(RecordingSession.self, from: data)
    }

    /// Delete a session by ID.
    func delete(sessionId: UUID) throws {
        let sessionFile = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        try FileManager.default.removeItem(at: sessionFile)
        sessions.removeAll { $0.id == sessionId }
        saveMetadata()
    }

    /// Delete all sessions.
    func deleteAll() throws {
        for session in sessions {
            let sessionFile = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
            try? FileManager.default.removeItem(at: sessionFile)
        }
        sessions.removeAll()
        saveMetadata()
    }

    /// Update a session's name and notes.
    func updateMetadata(sessionId: UUID, name: String?, notes: String?) throws {
        var session = try load(sessionId: sessionId)
        session.name = name
        session.notes = notes
        try save(session)
    }

    /// Get the total storage size used by sessions.
    var totalStorageSize: Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: sessionsDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }

    /// Formatted storage size string.
    var formattedStorageSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalStorageSize)
    }

    // MARK: - Private

    private func createDirectoryIfNeeded() {
        try? FileManager.default.createDirectory(
            at: sessionsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func loadMetadata() {
        guard FileManager.default.fileExists(atPath: metadataFile.path) else {
            sessions = []
            return
        }

        do {
            let data = try Data(contentsOf: metadataFile)
            sessions = try decoder.decode([SessionMetadata].self, from: data)
        } catch {
            print("Failed to load session metadata: \(error)")
            sessions = []
        }
    }

    private func saveMetadata() {
        do {
            let data = try encoder.encode(sessions)
            try data.write(to: metadataFile, options: .atomic)
        } catch {
            print("Failed to save session metadata: \(error)")
        }
    }
}
