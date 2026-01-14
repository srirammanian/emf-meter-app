package com.emfmeter.domain

import kotlin.math.sqrt

/**
 * Represents a single reading from the device's magnetometer.
 * All axis values are in microtesla (µT).
 */
data class EMFReading(
    val x: Float,
    val y: Float,
    val z: Float,
    val timestamp: Long
) {
    /**
     * Combined magnitude of all three axes.
     */
    val magnitude: Float
        get() = sqrt(x * x + y * y + z * z)

    companion object {
        val ZERO = EMFReading(0f, 0f, 0f, 0L)
    }
}

/**
 * Processed reading with calibration applied and normalized value for display.
 */
data class ProcessedReading(
    val rawReading: EMFReading,
    val calibratedReading: EMFReading,
    val magnitude: Float,
    val normalizedValue: Float  // 0.0 to 1.0 for meter display
)
