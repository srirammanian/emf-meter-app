import Foundation

/// Simulates realistic analog meter needle physics using a spring-damper system.
class NeedlePhysicsEngine {
    private let dampingFactor: Float
    private let springConstant: Float
    private let mass: Float
    private let noiseFactor: Float

    private var currentPosition: Float = 0
    private var velocity: Float = 0

    var position: Float { currentPosition }

    init(
        dampingFactor: Float = MeterConfig.needleDamping,
        springConstant: Float = MeterConfig.needleSpringConstant,
        mass: Float = MeterConfig.needleMass,
        noiseFactor: Float = MeterConfig.needleNoiseFactor
    ) {
        self.dampingFactor = dampingFactor
        self.springConstant = springConstant
        self.mass = mass
        self.noiseFactor = noiseFactor
    }

    /// Update needle position based on target value.
    func update(targetPosition: Float, deltaTime: Float) -> Float {
        let clampedTarget = min(max(targetPosition, 0), 1)

        // Spring-damper physics
        let displacement = clampedTarget - currentPosition
        let springForce = springConstant * displacement
        let dampingForce = dampingFactor * velocity
        let acceleration = (springForce - dampingForce) / mass

        velocity += acceleration * deltaTime
        currentPosition += velocity * deltaTime

        // Add slight random noise for realistic "jumpy" analog meter feel
        let noise: Float
        if abs(velocity) > 0.01 {
            noise = (Float.random(in: 0...1) - 0.5) * noiseFactor * abs(velocity)
        } else {
            noise = 0
        }

        currentPosition = min(max(currentPosition + noise, 0), 1)
        return currentPosition
    }

    /// Reset needle to starting position.
    func reset() {
        currentPosition = 0
        velocity = 0
    }

    /// Set needle position directly without physics.
    func setPosition(_ position: Float) {
        currentPosition = min(max(position, 0), 1)
        velocity = 0
    }
}
