package com.emfmeter.domain

/**
 * Configuration constants for the EMF meter.
 */
object MeterConfig {
    // Measurement range (in microtesla)
    const val MIN_VALUE_UT = 0f
    const val MAX_VALUE_UT = 200f  // 2000 mG

    // Sampling and display rates
    const val SAMPLE_RATE_HZ = 30
    const val DISPLAY_REFRESH_HZ = 60

    // Analog meter arc configuration (degrees)
    const val ARC_START_ANGLE = 225f    // Start angle from 3 o'clock position
    const val ARC_SWEEP_ANGLE = 90f     // Total arc sweep

    // Scale divisions
    const val MAJOR_DIVISIONS = 10
    const val MINOR_DIVISIONS = 2

    // Needle physics defaults
    const val NEEDLE_DAMPING = 0.7f
    const val NEEDLE_SPRING_CONSTANT = 120f
    const val NEEDLE_MASS = 1f
    const val NEEDLE_NOISE_FACTOR = 0.02f

    // Sound configuration
    const val MIN_CLICK_RATE = 0f       // Clicks per second at min EMF
    const val MAX_CLICK_RATE = 80f      // Clicks per second at max EMF
    const val CLICK_THRESHOLD = 0.05f   // Minimum normalized value to produce clicks
}

/**
 * Display mode for the meter UI.
 */
enum class DisplayMode {
    ANALOG,
    DIGITAL
}
