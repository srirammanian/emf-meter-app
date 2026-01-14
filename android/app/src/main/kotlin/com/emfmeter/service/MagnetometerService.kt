package com.emfmeter.service

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import com.emfmeter.domain.EMFReading
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import javax.inject.Inject

/**
 * Service for accessing the device's magnetometer sensor.
 * Emits EMFReading values through a SharedFlow.
 */
class MagnetometerService @Inject constructor(
    context: Context
) {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val magnetometer: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

    private val _readings = MutableSharedFlow<EMFReading>(replay = 1, extraBufferCapacity = 10)
    val readings: SharedFlow<EMFReading> = _readings.asSharedFlow()

    /**
     * Whether the magnetometer sensor is available on this device.
     */
    val isAvailable: Boolean = magnetometer != null

    private val sensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            if (event.sensor.type == Sensor.TYPE_MAGNETIC_FIELD) {
                val reading = EMFReading(
                    x = event.values[0],
                    y = event.values[1],
                    z = event.values[2],
                    timestamp = System.currentTimeMillis()
                )
                _readings.tryEmit(reading)
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Could track accuracy changes if needed
        }
    }

    /**
     * Start receiving magnetometer updates.
     */
    fun start() {
        magnetometer?.let { sensor ->
            sensorManager.registerListener(
                sensorListener,
                sensor,
                SensorManager.SENSOR_DELAY_GAME  // ~20ms interval, ~50Hz
            )
        }
    }

    /**
     * Stop receiving magnetometer updates.
     */
    fun stop() {
        sensorManager.unregisterListener(sensorListener)
    }
}
