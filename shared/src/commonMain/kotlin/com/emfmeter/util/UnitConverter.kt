package com.emfmeter.util

import com.emfmeter.domain.EMFUnit

/**
 * Utility for converting EMF values between units and formatting for display.
 */
object UnitConverter {

    /**
     * Convert a value from one unit to another.
     */
    fun convert(value: Float, from: EMFUnit, to: EMFUnit): Float {
        if (from == to) return value
        val microTesla = from.toMicroTesla(value)
        return to.fromMicroTesla(microTesla)
    }

    /**
     * Format a value for display with appropriate decimal places.
     */
    fun formatValue(value: Float, unit: EMFUnit): String {
        return when (unit) {
            EMFUnit.MICRO_TESLA -> formatFloat(value, 1)
            EMFUnit.MILLI_GAUSS -> formatFloat(value, 1)
            EMFUnit.GAUSS -> formatFloat(value, 3)
        }
    }

    /**
     * Format a float to a string with specified decimal places.
     * Uses platform-agnostic formatting.
     */
    private fun formatFloat(value: Float, decimals: Int): String {
        val factor = pow10(decimals)
        val rounded = kotlin.math.round(value * factor) / factor

        val intPart = rounded.toLong()
        val decPart = ((rounded - intPart) * factor).toLong()

        return if (decimals > 0) {
            "$intPart.${decPart.toString().padStart(decimals, '0')}"
        } else {
            intPart.toString()
        }
    }

    private fun pow10(n: Int): Float {
        var result = 1f
        repeat(n) { result *= 10f }
        return result
    }

    /**
     * Get the maximum display value for a unit (based on MAX_VALUE_UT = 200 µT).
     */
    fun getMaxDisplayValue(unit: EMFUnit): Float {
        return unit.fromMicroTesla(200f)
    }

    /**
     * Generate scale labels for the analog meter.
     */
    fun getScaleLabels(unit: EMFUnit, divisions: Int): List<String> {
        val maxValue = getMaxDisplayValue(unit)
        return (0..divisions).map { i ->
            val value = (maxValue * i / divisions)
            when (unit) {
                EMFUnit.GAUSS -> formatFloat(value, 1)
                else -> value.toInt().toString()
            }
        }
    }
}
