package com.emfmeter.domain

/**
 * Stores calibration offsets for the magnetometer.
 * When calibrating, the current reading becomes the new zero point.
 */
data class CalibrationData(
    val offsetX: Float = 0f,
    val offsetY: Float = 0f,
    val offsetZ: Float = 0f,
    val timestamp: Long = 0L
) {
    /**
     * Apply calibration offset to a reading.
     */
    fun apply(reading: EMFReading): EMFReading {
        return EMFReading(
            x = reading.x - offsetX,
            y = reading.y - offsetY,
            z = reading.z - offsetZ,
            timestamp = reading.timestamp
        )
    }

    val isCalibrated: Boolean
        get() = timestamp > 0L

    companion object {
        val NONE = CalibrationData()

        /**
         * Create calibration data from a reading.
         * The reading's values become the offset (new zero point).
         */
        fun fromReading(reading: EMFReading): CalibrationData {
            return CalibrationData(
                offsetX = reading.x,
                offsetY = reading.y,
                offsetZ = reading.z,
                timestamp = reading.timestamp
            )
        }
    }
}
