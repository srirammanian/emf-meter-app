package com.emfmeter.util

import com.emfmeter.domain.MeterConfig

/**
 * Calculates Geiger counter click rate based on EMF intensity.
 * Higher EMF readings produce more frequent clicks.
 */
object SoundClickCalculator {

    /**
     * Calculate clicks per second based on normalized EMF value.
     *
     * @param normalizedValue EMF reading normalized to 0.0-1.0 range
     * @return Clicks per second
     */
    fun calculateClickRate(normalizedValue: Float): Float {
        if (normalizedValue < MeterConfig.CLICK_THRESHOLD) {
            return 0f
        }

        // Non-linear curve for more dramatic effect at higher readings
        // Low readings: slow sporadic clicks
        // Mid readings: moderate clicking
        // High readings: rapid clicking
        return when {
            normalizedValue < 0.2f -> {
                // 0.05-0.2: 1-5 clicks per second
                1f + (normalizedValue - MeterConfig.CLICK_THRESHOLD) * 26.67f
            }
            normalizedValue < 0.5f -> {
                // 0.2-0.5: 5-20 clicks per second
                5f + (normalizedValue - 0.2f) * 50f
            }
            normalizedValue < 0.8f -> {
                // 0.5-0.8: 20-50 clicks per second
                20f + (normalizedValue - 0.5f) * 100f
            }
            else -> {
                // 0.8-1.0: 50-80 clicks per second
                50f + (normalizedValue - 0.8f) * 150f
            }
        }.coerceAtMost(MeterConfig.MAX_CLICK_RATE)
    }

    /**
     * Calculate interval between clicks in milliseconds.
     *
     * @param normalizedValue EMF reading normalized to 0.0-1.0 range
     * @return Milliseconds between clicks, or Long.MAX_VALUE if no clicks
     */
    fun calculateClickInterval(normalizedValue: Float): Long {
        val rate = calculateClickRate(normalizedValue)
        return if (rate > 0f) {
            (1000f / rate).toLong()
        } else {
            Long.MAX_VALUE
        }
    }

    /**
     * Determine if a click should be played based on time since last click.
     *
     * @param normalizedValue Current normalized EMF reading
     * @param timeSinceLastClickMs Milliseconds since the last click was played
     * @return True if a click should be played now
     */
    fun shouldPlayClick(normalizedValue: Float, timeSinceLastClickMs: Long): Boolean {
        val interval = calculateClickInterval(normalizedValue)
        return interval != Long.MAX_VALUE && timeSinceLastClickMs >= interval
    }
}
