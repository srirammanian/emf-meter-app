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
            // 0.05-0.2: 1-5 clicks per second
            return 1 + (normalizedValue - MeterConfig.clickThreshold) * 26.67
        case ..<0.5:
            // 0.2-0.5: 5-20 clicks per second
            return 5 + (normalizedValue - 0.2) * 50
        case ..<0.8:
            // 0.5-0.8: 20-50 clicks per second
            return 20 + (normalizedValue - 0.5) * 100
        default:
            // 0.8-1.0: 50-80 clicks per second
            return min(50 + (normalizedValue - 0.8) * 150, MeterConfig.maxClickRate)
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
