package com.emfmeter.domain

/**
 * Supported units for EMF measurement display.
 * All internal calculations use microtesla (µT) as the base unit.
 */
enum class EMFUnit(
    val symbol: String,
    val displayName: String
) {
    MICRO_TESLA("µT", "MicroTesla"),
    MILLI_GAUSS("mG", "MilliGauss"),
    GAUSS("G", "Gauss");

    /**
     * Convert a value from microtesla to this unit.
     */
    fun fromMicroTesla(value: Float): Float {
        return when (this) {
            MICRO_TESLA -> value
            MILLI_GAUSS -> value * 10f      // 1 µT = 10 mG
            GAUSS -> value / 100f           // 1 G = 100 µT
        }
    }

    /**
     * Convert a value from this unit to microtesla.
     */
    fun toMicroTesla(value: Float): Float {
        return when (this) {
            MICRO_TESLA -> value
            MILLI_GAUSS -> value / 10f      // 10 mG = 1 µT
            GAUSS -> value * 100f           // 1 G = 100 µT
        }
    }

    companion object {
        val DEFAULT = MILLI_GAUSS

        fun fromSymbol(symbol: String): EMFUnit? {
            return entries.find { it.symbol == symbol }
        }

        fun fromName(name: String): EMFUnit? {
            return try {
                valueOf(name)
            } catch (e: IllegalArgumentException) {
                null
            }
        }
    }
}
