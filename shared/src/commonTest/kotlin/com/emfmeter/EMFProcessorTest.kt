package com.emfmeter

import com.emfmeter.data.CalibrationManager
import com.emfmeter.data.EMFProcessor
import com.emfmeter.domain.CalibrationData
import com.emfmeter.domain.EMFReading
import com.emfmeter.domain.EMFUnit
import com.emfmeter.util.UnitConverter
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class EMFProcessorTest {

    @Test
    fun testMagnitudeCalculation() {
        val reading = EMFReading(3f, 4f, 0f, System.currentTimeMillis())
        assertEquals(5f, reading.magnitude, 0.001f)
    }

    @Test
    fun testMagnitudeCalculation3D() {
        // 3-4-5 scaled: sqrt(30^2 + 40^2 + 0^2) = 50
        val reading = EMFReading(30f, 40f, 0f, System.currentTimeMillis())
        assertEquals(50f, reading.magnitude, 0.001f)
    }

    @Test
    fun testCalibrationApplied() {
        val calibration = CalibrationData(10f, 20f, 30f, 1L)
        val reading = EMFReading(15f, 25f, 35f, System.currentTimeMillis())
        val calibrated = calibration.apply(reading)

        assertEquals(5f, calibrated.x, 0.001f)
        assertEquals(5f, calibrated.y, 0.001f)
        assertEquals(5f, calibrated.z, 0.001f)
    }

    @Test
    fun testProcessorNormalization() {
        val manager = CalibrationManager()
        val processor = EMFProcessor(manager)

        // 200 µT should normalize to 1.0
        val reading = EMFReading(200f, 0f, 0f, System.currentTimeMillis())
        val processed = processor.process(reading)

        assertEquals(1f, processed.normalizedValue, 0.001f)
    }

    @Test
    fun testProcessorNormalizationClamped() {
        val manager = CalibrationManager()
        val processor = EMFProcessor(manager)

        // Values above max should clamp to 1.0
        val reading = EMFReading(300f, 0f, 0f, System.currentTimeMillis())
        val processed = processor.process(reading)

        assertEquals(1f, processed.normalizedValue, 0.001f)
    }

    @Test
    fun testUnitConversion() {
        // 1 µT = 10 mG
        val milliGauss = UnitConverter.convert(1f, EMFUnit.MICRO_TESLA, EMFUnit.MILLI_GAUSS)
        assertEquals(10f, milliGauss, 0.001f)

        // 100 µT = 1 G
        val gauss = UnitConverter.convert(100f, EMFUnit.MICRO_TESLA, EMFUnit.GAUSS)
        assertEquals(1f, gauss, 0.001f)

        // Round trip
        val original = 50f
        val converted = UnitConverter.convert(
            UnitConverter.convert(original, EMFUnit.MILLI_GAUSS, EMFUnit.MICRO_TESLA),
            EMFUnit.MICRO_TESLA,
            EMFUnit.MILLI_GAUSS
        )
        assertEquals(original, converted, 0.001f)
    }

    @Test
    fun testValueFormatting() {
        assertEquals("123.5", UnitConverter.formatValue(123.45f, EMFUnit.MILLI_GAUSS))
        assertEquals("1.234", UnitConverter.formatValue(1.2344f, EMFUnit.GAUSS))
    }
}
