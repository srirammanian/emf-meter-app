import Foundation
import Combine
import UIKit
import SwiftUI

/// Handles EMF session recording with background support.
class RecordingService: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var currentSession: RecordingSession?
    @Published private(set) var recordingDuration: TimeInterval = 0
    @Published private(set) var liveReadings: [TimestampedReading] = []

    // MARK: - Configuration
    @AppStorage("maxBackgroundDuration") var maxBackgroundDuration: TimeInterval = RecordingConfig.defaultMaxBackgroundDuration

    // MARK: - Private
    private var readings: [TimestampedReading] = []
    private var sessionStartTime: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var durationTimer: Timer?
    private let maxLiveReadings = 1800  // 30 seconds at 60Hz

    // MARK: - Recording Control

    /// Start a new recording session.
    func startRecording() {
        guard !isRecording else { return }

        sessionStartTime = Date()
        readings = []
        // Keep liveReadings to maintain oscilloscope continuity
        isRecording = true
        recordingDuration = 0

        currentSession = RecordingSession(
            id: UUID(),
            name: nil,
            notes: nil,
            startTime: sessionStartTime!,
            endTime: nil,
            readings: []
        )

        startDurationTimer()
        registerBackgroundTask()
    }

    /// Stop the current recording and return the completed session.
    func stopRecording() -> RecordingSession? {
        guard isRecording, var session = currentSession else { return nil }

        isRecording = false
        session.endTime = Date()
        session.readings = readings

        durationTimer?.invalidate()
        durationTimer = nil
        endBackgroundTask()

        currentSession = nil
        readings = []
        // Keep liveReadings for display after stop

        return session
    }

    /// Add a reading to the current recording session.
    /// - Parameters:
    ///   - reading: The EMF reading to add
    ///   - elapsed: Elapsed time since app start, used for live display continuity
    func addReading(_ reading: EMFReading, elapsed: TimeInterval) {
        guard isRecording, let startTime = sessionStartTime else { return }

        // Use session-relative timestamp for the recording
        let sessionTimestamp = Date().timeIntervalSince(startTime)
        let recordingTimestamped = TimestampedReading(
            timestamp: sessionTimestamp,
            reading: reading
        )
        readings.append(recordingTimestamped)

        // Use app-relative timestamp for live display to maintain continuity
        let liveTimestamped = TimestampedReading(timestamp: elapsed, reading: reading)
        liveReadings.append(liveTimestamped)
        if liveReadings.count > maxLiveReadings {
            liveReadings.removeFirst(liveReadings.count - maxLiveReadings)
        }
    }

    /// Add a reading for live display only (when not recording).
    func addLiveReading(_ reading: EMFReading, elapsed: TimeInterval) {
        let timestamped = TimestampedReading(timestamp: elapsed, reading: reading)
        liveReadings.append(timestamped)
        if liveReadings.count > maxLiveReadings {
            liveReadings.removeFirst(liveReadings.count - maxLiveReadings)
        }
    }

    /// Clear live readings buffer.
    func clearLiveReadings() {
        liveReadings = []
    }

    // MARK: - Background Support

    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "EMFRecording") { [weak self] in
            self?.handleBackgroundExpiration()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func handleBackgroundExpiration() {
        // Auto-stop recording when background time expires or max duration reached
        if isRecording {
            _ = stopRecording()
        }
        endBackgroundTask()
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.sessionStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)

            // Auto-stop if max background duration exceeded
            if self.recordingDuration >= self.maxBackgroundDuration {
                _ = self.stopRecording()
            }
        }
    }

    // MARK: - Formatted Duration

    var formattedDuration: String {
        let hours = Int(recordingDuration) / 3600
        let minutes = (Int(recordingDuration) % 3600) / 60
        let seconds = Int(recordingDuration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
