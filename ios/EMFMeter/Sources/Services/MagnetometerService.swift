import Foundation
import CoreMotion
import Combine

/// Protocol defining the magnetometer service interface.
/// Enables dependency injection and mocking for simulator/testing.
protocol MagnetometerServiceProtocol: ObservableObject {
    var currentReading: EMFReading? { get }
    var currentReadingPublisher: Published<EMFReading?>.Publisher { get }
    var isAvailable: Bool { get }
    var isAvailablePublisher: Published<Bool>.Publisher { get }

    func start()
    func stop()
}

// MARK: - Type-Erased Wrapper

/// Type-erased wrapper for MagnetometerServiceProtocol.
/// Allows storing any magnetometer service implementation without generics.
class AnyMagnetometerService: ObservableObject {
    @Published private(set) var currentReading: EMFReading?
    @Published private(set) var isAvailable: Bool

    private let _start: () -> Void
    private let _stop: () -> Void
    private var cancellables = Set<AnyCancellable>()

    init<T: MagnetometerServiceProtocol>(_ service: T) {
        self.currentReading = service.currentReading
        self.isAvailable = service.isAvailable
        self._start = { service.start() }
        self._stop = { service.stop() }

        // Forward published values
        service.currentReadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reading in
                self?.currentReading = reading
            }
            .store(in: &cancellables)

        service.isAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] available in
                self?.isAvailable = available
            }
            .store(in: &cancellables)
    }

    func start() { _start() }
    func stop() { _stop() }
}

/// Service for accessing the device's magnetometer sensor.
class MagnetometerService: ObservableObject, MagnetometerServiceProtocol {
    private let motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var currentReading: EMFReading?
    @Published private(set) var isAvailable: Bool = false

    var currentReadingPublisher: Published<EMFReading?>.Publisher { $currentReading }
    var isAvailablePublisher: Published<Bool>.Publisher { $isAvailable }

    init() {
        isAvailable = motionManager.isMagnetometerAvailable
    }

    /// Start receiving magnetometer updates.
    func start() {
        guard motionManager.isMagnetometerAvailable else {
            isAvailable = false
            return
        }

        motionManager.magnetometerUpdateInterval = 1.0 / Double(MeterConfig.sampleRateHz)

        motionManager.startMagnetometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else {
                return
            }

            self?.currentReading = EMFReading(
                x: Float(data.magneticField.x),
                y: Float(data.magneticField.y),
                z: Float(data.magneticField.z),
                timestamp: Date().timeIntervalSince1970
            )
        }
    }

    /// Stop receiving magnetometer updates.
    func stop() {
        motionManager.stopMagnetometerUpdates()
    }

    deinit {
        stop()
    }
}

// MARK: - Mock Magnetometer Service

/// Mock magnetometer service for simulator testing and UI automation.
/// Generates realistic-looking simulated EMF readings.
class MockMagnetometerService: ObservableObject, MagnetometerServiceProtocol {
    @Published private(set) var currentReading: EMFReading?
    @Published private(set) var isAvailable: Bool = true

    var currentReadingPublisher: Published<EMFReading?>.Publisher { $currentReading }
    var isAvailablePublisher: Published<Bool>.Publisher { $isAvailable }

    private var timer: Timer?
    private var simulationState = SimulationState()

    /// Configuration for the simulation behavior.
    struct SimulationConfig {
        /// Base EMF level in microtesla (Earth's field is ~25-65 µT)
        var baseLevel: Float = 45.0
        /// Maximum random variation from base
        var variationRange: Float = 30.0
        /// How quickly the field changes (0-1, higher = faster)
        var changeSpeed: Float = 0.1
        /// Probability of a "spike" event per second
        var spikeChance: Float = 0.05
        /// Magnitude multiplier during spikes
        var spikeMagnitude: Float = 3.0
    }

    private var config: SimulationConfig

    init(config: SimulationConfig = SimulationConfig()) {
        self.config = config
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(MeterConfig.sampleRateHz), repeats: true) { [weak self] _ in
            self?.generateReading()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func generateReading() {
        simulationState.update(config: config)

        let reading = EMFReading(
            x: simulationState.x,
            y: simulationState.y,
            z: simulationState.z,
            timestamp: Date().timeIntervalSince1970
        )

        currentReading = reading
    }

    deinit {
        stop()
    }
}

// MARK: - Simulation State

/// Internal state for generating smooth, realistic EMF variations.
private struct SimulationState {
    var x: Float = 0
    var y: Float = 0
    var z: Float = 0

    // Target values for smooth interpolation
    private var targetX: Float = 0
    private var targetY: Float = 0
    private var targetZ: Float = 0

    // Time tracking for periodic behavior
    private var phase: Float = 0
    private var spikeTimer: Float = 0
    private var inSpike: Bool = false

    mutating func update(config: MockMagnetometerService.SimulationConfig) {
        phase += 0.02

        // Occasionally pick new target values
        if Float.random(in: 0...1) < config.changeSpeed * 0.1 {
            let angle1 = Float.random(in: 0...(2 * .pi))
            let angle2 = Float.random(in: 0...(2 * .pi))
            let variation = Float.random(in: 0...config.variationRange)

            targetX = config.baseLevel * cos(angle1) + variation * sin(phase)
            targetY = config.baseLevel * sin(angle1) * cos(angle2) + variation * cos(phase * 1.3)
            targetZ = config.baseLevel * sin(angle2) + variation * sin(phase * 0.7)
        }

        // Check for spike events
        if !inSpike && Float.random(in: 0...1) < config.spikeChance / Float(MeterConfig.sampleRateHz) {
            inSpike = true
            spikeTimer = Float.random(in: 0.5...2.0) // Spike duration in seconds
            targetX *= config.spikeMagnitude
            targetY *= config.spikeMagnitude
            targetZ *= config.spikeMagnitude
        }

        if inSpike {
            spikeTimer -= 1.0 / Float(MeterConfig.sampleRateHz)
            if spikeTimer <= 0 {
                inSpike = false
            }
        }

        // Smooth interpolation toward targets
        let smoothing: Float = 0.08
        x += (targetX - x) * smoothing
        y += (targetY - y) * smoothing
        z += (targetZ - z) * smoothing

        // Add subtle noise
        let noiseAmount: Float = 0.5
        x += Float.random(in: -noiseAmount...noiseAmount)
        y += Float.random(in: -noiseAmount...noiseAmount)
        z += Float.random(in: -noiseAmount...noiseAmount)
    }
}

// MARK: - Service Factory

/// Factory for creating the appropriate magnetometer service based on environment.
enum MagnetometerServiceFactory {
    /// Creates a magnetometer service appropriate for the current environment.
    /// Returns MockMagnetometerService on simulator, real MagnetometerService on device.
    static func create() -> any MagnetometerServiceProtocol {
        #if targetEnvironment(simulator)
        return MockMagnetometerService()
        #else
        return MagnetometerService()
        #endif
    }

    /// Creates a mock service with custom configuration.
    static func createMock(config: MockMagnetometerService.SimulationConfig = .init()) -> MockMagnetometerService {
        return MockMagnetometerService(config: config)
    }
}
