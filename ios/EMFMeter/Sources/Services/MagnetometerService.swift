import Foundation
import CoreMotion
import Combine

/// Service for accessing the device's magnetometer sensor.
class MagnetometerService: ObservableObject {
    private let motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var currentReading: EMFReading?
    @Published private(set) var isAvailable: Bool = false

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
