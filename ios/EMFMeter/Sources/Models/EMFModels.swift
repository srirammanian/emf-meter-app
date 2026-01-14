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
