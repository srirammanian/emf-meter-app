package com.emfmeter.data

import com.emfmeter.domain.MeterConfig
import kotlin.math.abs
import kotlin.random.Random

/**
 * Simulates realistic analog meter needle physics using a spring-damper system.
 * Creates natural inertia, overshoot, and slight "jumpy" behavior.
 */
class NeedlePhysicsEngine(
    private val dampingFactor: Float = MeterConfig.NEEDLE_DAMPING,
    private val springConstant: Float = MeterConfig.NEEDLE_SPRING_CONSTANT,
    private val mass: Float = MeterConfig.NEEDLE_MASS,
    private val noiseFactor: Float = MeterConfig.NEEDLE_NOISE_FACTOR
) {
    private var currentPosition: Float = 0f
    private var velocity: Float = 0f

    /**
     * Current needle position (0.0 to 1.0).
     */
    val position: Float
        get() = currentPosition

    /**
     * Update needle position based on target value.
     *
     * @param targetPosition Target position (0.0 to 1.0)
     * @param deltaTime Time since last update in seconds
     * @return Updated needle position (0.0 to 1.0)
     */
    fun update(targetPosition: Float, deltaTime: Float): Float {
        val clampedTarget = targetPosition.coerceIn(0f, 1f)

        // Spring-damper physics
        val displacement = clampedTarget - currentPosition
        val springForce = springConstant * displacement
        val dampingForce = dampingFactor * velocity
        val acceleration = (springForce - dampingForce) / mass

        velocity += acceleration * deltaTime
        currentPosition += velocity * deltaTime

        // Add slight random noise for realistic "jumpy" analog meter feel
        // Noise is proportional to velocity (more jitter when moving fast)
        val noise = if (abs(velocity) > 0.01f) {
            (Random.nextFloat() - 0.5f) * noiseFactor * abs(velocity)
        } else {
            0f
        }

        currentPosition = (currentPosition + noise).coerceIn(0f, 1f)

        return currentPosition
    }

    /**
     * Reset needle to starting position.
     */
    fun reset() {
        currentPosition = 0f
        velocity = 0f
    }

    /**
     * Set needle position directly without physics (for initialization).
     */
    fun setPosition(position: Float) {
        currentPosition = position.coerceIn(0f, 1f)
        velocity = 0f
    }
}
