import Foundation
import UniformTypeIdentifiers

/// Generates CSV files for session export.
class ExportService {

    /// Generate a CSV file from a recording session.
    /// - Parameters:
    ///   - session: The recording session to export
    ///   - unit: The unit to use for values in the export
    /// - Returns: URL to the generated CSV file, or nil if generation failed
    func generateCSV(from session: RecordingSession, unit: EMFUnit) -> URL? {
        // Build CSV header
        var csvContent = "Timestamp (s),X (\(unit.symbol)),Y (\(unit.symbol)),Z (\(unit.symbol)),Magnitude (\(unit.symbol))\n"

        // Add readings
        for reading in session.readings {
            let x = unit.fromMicroTesla(reading.x)
            let y = unit.fromMicroTesla(reading.y)
            let z = unit.fromMicroTesla(reading.z)
            let magnitude = unit.fromMicroTesla(reading.magnitude)

            csvContent += String(format: "%.3f,%.2f,%.2f,%.2f,%.2f\n",
                                 reading.timestamp, x, y, z, magnitude)
        }

        // Create temp file with descriptive name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = dateFormatter.string(from: session.startTime)

        let sessionName = session.name?.replacingOccurrences(of: " ", with: "_") ?? "Session"
        let filename = "EMF_\(sessionName)_\(dateString).csv"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }

    /// Generate session summary text.
    func generateSummary(from session: RecordingSession, unit: EMFUnit) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let stats = session.statistics
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        durationFormatter.unitsStyle = .abbreviated

        var summary = """
        EMF Recording Session
        =====================

        Name: \(session.name ?? "Untitled")
        Date: \(dateFormatter.string(from: session.startTime))
        Duration: \(durationFormatter.string(from: session.duration) ?? "Unknown")
        Readings: \(stats.readingCount)

        Statistics (\(unit.symbol)):
        - Minimum: \(String(format: "%.2f", unit.fromMicroTesla(stats.minMagnitude)))
        - Maximum: \(String(format: "%.2f", unit.fromMicroTesla(stats.maxMagnitude)))
        - Average: \(String(format: "%.2f", unit.fromMicroTesla(stats.avgMagnitude)))
        """

        if let notes = session.notes, !notes.isEmpty {
            summary += "\n\nNotes:\n\(notes)"
        }

        return summary
    }
}
