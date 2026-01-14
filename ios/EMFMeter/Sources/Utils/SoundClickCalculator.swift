import Foundation

/// Calculates Geiger counter click rate based on EMF intensity.
enum SoundClickCalculator {

    /// Calculate clicks per second based on normalized EMF value.
    static func calculateClickRate(normalizedValue: Float) -> Float {
        if normalizedValue < MeterConfig.clickThreshold {
            return 0
        }

        switch normalizedValue {
        case ..<0.2:
            // 0.05-0.2: 0.5-2 clicks per second
            return 0.5 + (normalizedValue - MeterConfig.clickThreshold) * 10
        case ..<0.5:
            // 0.2-0.5: 2-6 clicks per second
            return 2 + (normalizedValue - 0.2) * 13.3
        case ..<0.8:
            // 0.5-0.8: 6-12 clicks per second
            return 6 + (normalizedValue - 0.5) * 20
        default:
            // 0.8-1.0: 12-18 clicks per second
            return min(12 + (normalizedValue - 0.8) * 30, 18)
        }
    }

    /// Calculate interval between clicks in seconds.
    static func calculateClickInterval(normalizedValue: Float) -> TimeInterval {
        let rate = calculateClickRate(normalizedValue: normalizedValue)
        return rate > 0 ? 1.0 / Double(rate) : .infinity
    }

    /// Determine if a click should be played based on time since last click.
    static func shouldPlayClick(normalizedValue: Float, timeSinceLastClick: TimeInterval) -> Bool {
        let interval = calculateClickInterval(normalizedValue: normalizedValue)
        return interval != .infinity && timeSinceLastClick >= interval
    }
}
