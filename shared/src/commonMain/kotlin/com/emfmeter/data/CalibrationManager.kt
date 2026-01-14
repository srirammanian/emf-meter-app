package com.emfmeter.data

import com.emfmeter.domain.CalibrationData
import com.emfmeter.domain.EMFReading

/**
 * Manages calibration state for the EMF meter.
 * Calibration sets the current reading as the new zero point.
 */
class CalibrationManager(
    initialCalibration: CalibrationData = CalibrationData.NONE
) {
    private var calibrationData: CalibrationData = initialCalibration

    val isCalibrated: Boolean
        get() = calibrationData.isCalibrated

    val currentCalibration: CalibrationData
        get() = calibrationData

    /**
     * Apply current calibration to a reading.
     */
    fun apply(reading: EMFReading): EMFReading {
        return calibrationData.apply(reading)
    }

    /**
     * Calibrate using the given reading as the new zero point.
     */
    fun calibrate(reading: EMFReading): CalibrationData {
        calibrationData = CalibrationData.fromReading(reading)
        return calibrationData
    }

    /**
     * Reset calibration to default (no offset).
     */
    fun reset() {
        calibrationData = CalibrationData.NONE
    }

    /**
     * Restore calibration from saved data.
     */
    fun restore(data: CalibrationData) {
        calibrationData = data
    }
}
