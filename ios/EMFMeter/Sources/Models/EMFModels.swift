import Foundation

/// Represents a single reading from the device's magnetometer.
/// All axis values are in microtesla (µT).
struct EMFReading: Equatable {
    let x: Float
    let y: Float
    let z: Float
    let timestamp: TimeInterval

    /// Combined magnitude of all three axes.
    var magnitude: Float {
        sqrt(x * x + y * y + z * z)
    }

    static let zero = EMFReading(x: 0, y: 0, z: 0, timestamp: 0)
}

/// Processed reading with calibration applied and normalized value for display.
struct ProcessedReading: Equatable {
    let rawReading: EMFReading
    let calibratedReading: EMFReading
    let magnitude: Float
    let normalizedValue: Float  // 0.0 to 1.0 for meter display
}

/// Supported units for EMF measurement display.
enum EMFUnit: String, CaseIterable, Identifiable {
    case microTesla = "MICRO_TESLA"
    case milliGauss = "MILLI_GAUSS"
    case gauss = "GAUSS"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .microTesla: return "µT"
        case .milliGauss: return "mG"
        case .gauss: return "G"
        }
    }

    var displayName: String {
        switch self {
        case .microTesla: return "MicroTesla"
        case .milliGauss: return "MilliGauss"
        case .gauss: return "Gauss"
        }
    }

    /// Full name for VoiceOver accessibility
    var accessibilityName: String {
        switch self {
        case .microTesla: return "microtesla"
        case .milliGauss: return "milligauss"
        case .gauss: return "gauss"
        }
    }

    /// Convert a value from microtesla to this unit.
    func fromMicroTesla(_ value: Float) -> Float {
        switch self {
        case .microTesla: return value
        case .milliGauss: return value * 10  // 1 µT = 10 mG
        case .gauss: return value / 100      // 1 G = 100 µT
        }
    }

    /// Convert a value from this unit to microtesla.
    func toMicroTesla(_ value: Float) -> Float {
        switch self {
        case .microTesla: return value
        case .milliGauss: return value / 10  // 10 mG = 1 µT
        case .gauss: return value * 100      // 1 G = 100 µT
        }
    }

    static let `default`: EMFUnit = .milliGauss
}

/// Stores calibration offsets for the magnetometer.
struct CalibrationData: Codable, Equatable {
    let offsetX: Float
    let offsetY: Float
    let offsetZ: Float
    let timestamp: TimeInterval

    var isCalibrated: Bool {
        timestamp > 0
    }

    func apply(to reading: EMFReading) -> EMFReading {
        EMFReading(
            x: reading.x - offsetX,
            y: reading.y - offsetY,
            z: reading.z - offsetZ,
            timestamp: reading.timestamp
        )
    }

    static let none = CalibrationData(offsetX: 0, offsetY: 0, offsetZ: 0, timestamp: 0)

    static func from(reading: EMFReading) -> CalibrationData {
        CalibrationData(
            offsetX: reading.x,
            offsetY: reading.y,
            offsetZ: reading.z,
            timestamp: reading.timestamp
        )
    }
}

/// Display mode for the meter UI.
enum DisplayMode: String, CaseIterable, Identifiable {
    case analog = "ANALOG"
    case digital = "DIGITAL"

    var id: String { rawValue }
}

/// Configuration constants for the EMF meter.
enum MeterConfig {
    static let minValueUT: Float = 0
    static let maxValueUT: Float = 200  // 2000 mG

    static let sampleRateHz = 30
    static let displayRefreshHz = 60

    static let arcStartAngle: Float = 225
    static let arcSweepAngle: Float = 90

    static let majorDivisions = 10
    static let minorDivisions = 2

    static let needleDamping: Float = 0.7
    static let needleSpringConstant: Float = 120
    static let needleMass: Float = 1
    static let needleNoiseFactor: Float = 0.02

    static let minClickRate: Float = 0
    static let maxClickRate: Float = 80
    static let clickThreshold: Float = 0.05
}

// MARK: - V2 Pro Features Models

/// A single timestamped reading for recording sessions.
struct TimestampedReading: Codable, Equatable {
    let timestamp: TimeInterval  // Seconds since session start
    let x: Float
    let y: Float
    let z: Float
    let magnitude: Float

    init(timestamp: TimeInterval, reading: EMFReading) {
        self.timestamp = timestamp
        self.x = reading.x
        self.y = reading.y
        self.z = reading.z
        self.magnitude = reading.magnitude
    }

    init(timestamp: TimeInterval, x: Float, y: Float, z: Float, magnitude: Float) {
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.z = z
        self.magnitude = magnitude
    }
}

/// Statistics calculated from a session's readings.
struct SessionStatistics: Codable, Equatable {
    let minMagnitude: Float
    let maxMagnitude: Float
    let avgMagnitude: Float
    let readingCount: Int

    init(readings: [TimestampedReading]) {
        guard !readings.isEmpty else {
            self.minMagnitude = 0
            self.maxMagnitude = 0
            self.avgMagnitude = 0
            self.readingCount = 0
            return
        }
        self.minMagnitude = readings.map(\.magnitude).min() ?? 0
        self.maxMagnitude = readings.map(\.magnitude).max() ?? 0
        self.avgMagnitude = readings.map(\.magnitude).reduce(0, +) / Float(readings.count)
        self.readingCount = readings.count
    }

    static let empty = SessionStatistics(readings: [])
}

/// A complete recording session with all readings.
struct RecordingSession: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String?
    var notes: String?
    let startTime: Date
    var endTime: Date?
    var readings: [TimestampedReading]

    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }

    var statistics: SessionStatistics {
        SessionStatistics(readings: readings)
    }

    init(id: UUID = UUID(), name: String? = nil, notes: String? = nil, startTime: Date = Date(), endTime: Date? = nil, readings: [TimestampedReading] = []) {
        self.id = id
        self.name = name
        self.notes = notes
        self.startTime = startTime
        self.endTime = endTime
        self.readings = readings
    }
}

/// Lightweight metadata for session list display.
struct SessionMetadata: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String?
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let readingCount: Int
    let minMagnitude: Float
    let maxMagnitude: Float
    let avgMagnitude: Float

    init(from session: RecordingSession) {
        self.id = session.id
        self.name = session.name
        self.startTime = session.startTime
        self.endTime = session.endTime ?? Date()
        self.duration = session.duration
        self.readingCount = session.readings.count
        let stats = session.statistics
        self.minMagnitude = stats.minMagnitude
        self.maxMagnitude = stats.maxMagnitude
        self.avgMagnitude = stats.avgMagnitude
    }
}

/// Recording configuration constants.
enum RecordingConfig {
    static let defaultMaxBackgroundDuration: TimeInterval = 3600  // 1 hour
    static let maxBackgroundDuration: TimeInterval = 10800        // 3 hours
    static let minBackgroundDuration: TimeInterval = 300          // 5 minutes
}
