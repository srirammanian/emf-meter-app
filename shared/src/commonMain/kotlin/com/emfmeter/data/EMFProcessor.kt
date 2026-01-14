package com.emfmeter.data

import com.emfmeter.domain.EMFReading
import com.emfmeter.domain.MeterConfig
import com.emfmeter.domain.ProcessedReading

/**
 * Processes raw magnetometer readings into displayable values.
 */
class EMFProcessor(
    private val calibrationManager: CalibrationManager
) {
    /**
     * Process a raw reading, applying calibration and normalization.
     */
    fun process(reading: EMFReading): ProcessedReading {
        val calibrated = calibrationManager.apply(reading)
        val magnitude = calibrated.magnitude

        // Normalize to 0-1 range for meter display
        val normalized = (magnitude / MeterConfig.MAX_VALUE_UT).coerceIn(0f, 1f)

        return ProcessedReading(
            rawReading = reading,
            calibratedReading = calibrated,
            magnitude = magnitude,
            normalizedValue = normalized
        )
    }
}
