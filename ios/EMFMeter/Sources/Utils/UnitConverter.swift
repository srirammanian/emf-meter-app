import Foundation

/// Utility for converting EMF values between units and formatting for display.
enum UnitConverter {

    /// Convert a value from one unit to another.
    static func convert(_ value: Float, from: EMFUnit, to: EMFUnit) -> Float {
        if from == to { return value }
        let microTesla = from.toMicroTesla(value)
        return to.fromMicroTesla(microTesla)
    }

    /// Format a value for display with appropriate decimal places.
    static func formatValue(_ value: Float, unit: EMFUnit) -> String {
        switch unit {
        case .microTesla:
            return String(format: "%.1f", value)
        case .milliGauss:
            return String(format: "%.1f", value)
        case .gauss:
            return String(format: "%.3f", value)
        }
    }

    /// Get the maximum display value for a unit (based on MAX_VALUE_UT = 200 µT).
    static func getMaxDisplayValue(for unit: EMFUnit) -> Float {
        unit.fromMicroTesla(200)
    }

    /// Generate scale labels for the analog meter.
    static func getScaleLabels(for unit: EMFUnit, divisions: Int) -> [String] {
        let maxValue = getMaxDisplayValue(for: unit)
        return (0...divisions).map { i in
            let value = maxValue * Float(i) / Float(divisions)
            switch unit {
            case .gauss:
                return String(format: "%.1f", value)
            default:
                return String(Int(value))
            }
        }
    }
}
