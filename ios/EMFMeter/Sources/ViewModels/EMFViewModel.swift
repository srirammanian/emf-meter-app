import SwiftUI
import Combine

/// ViewModel for the EMF Meter.
@MainActor
class EMFViewModel: ObservableObject {
    // Services
    private let magnetometerService = MagnetometerService()
    private let audioService = AudioService()
    private let needlePhysics = NeedlePhysicsEngine()

    // Calibration
    private var calibrationData: CalibrationData = .none

    // Display link for animation
    private var displayLink: CADisplayLink?
    private var cancellables = Set<AnyCancellable>()

    // Published state
    @Published var needlePosition: Float = 0
    @Published var displayValue: Float = 0
    @Published var displayMode: DisplayMode = .analog
    @Published var selectedUnit: EMFUnit = .milliGauss
    @Published var soundEnabled: Bool = true
    @Published var isCalibrated: Bool = false
    @Published var sensorAvailable: Bool = true
    @Published var showSettings: Bool = false
    @Published var theme: String = "system"

    // Current processed reading
    private var currentReading: ProcessedReading?

    // UserDefaults keys
    private enum Keys {
        static let unit = "selectedUnit"
        static let soundEnabled = "soundEnabled"
        static let displayMode = "displayMode"
        static let theme = "theme"
        static let calibrationX = "calibrationX"
        static let calibrationY = "calibrationY"
        static let calibrationZ = "calibrationZ"
        static let calibrationTimestamp = "calibrationTimestamp"
    }

    init() {
        loadSettings()
        setupBindings()
        setupDisplayLink()
        sensorAvailable = magnetometerService.isAvailable
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard

        // Load unit
        if let unitString = defaults.string(forKey: Keys.unit),
           let unit = EMFUnit(rawValue: unitString) {
            selectedUnit = unit
        }

        // Load sound
        soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        audioService.isEnabled = soundEnabled

        // Load display mode
        if let modeString = defaults.string(forKey: Keys.displayMode),
           let mode = DisplayMode(rawValue: modeString) {
            displayMode = mode
        }

        // Load theme
        theme = defaults.string(forKey: Keys.theme) ?? "system"

        // Load calibration
        let calibrationTimestamp = defaults.double(forKey: Keys.calibrationTimestamp)
        if calibrationTimestamp > 0 {
            calibrationData = CalibrationData(
                offsetX: defaults.float(forKey: Keys.calibrationX),
                offsetY: defaults.float(forKey: Keys.calibrationY),
                offsetZ: defaults.float(forKey: Keys.calibrationZ),
                timestamp: calibrationTimestamp
            )
            isCalibrated = true
        }
    }

    private func setupBindings() {
        magnetometerService.$currentReading
            .compactMap { $0 }
            .sink { [weak self] reading in
                self?.processReading(reading)
            }
            .store(in: &cancellables)
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateNeedle))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 30,
            maximum: 60,
            preferred: 60
        )
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateNeedle() {
        guard let reading = currentReading else { return }

        let newPosition = needlePhysics.update(
            targetPosition: reading.normalizedValue,
            deltaTime: 1.0 / Float(MeterConfig.displayRefreshHz)
        )
        needlePosition = newPosition

        if soundEnabled && displayMode == .analog {
            audioService.playClickIfNeeded(normalizedValue: reading.normalizedValue)
        }
    }

    private func processReading(_ reading: EMFReading) {
        let calibrated = calibrationData.apply(to: reading)
        let magnitude = calibrated.magnitude
        let normalized = min(max(magnitude / MeterConfig.maxValueUT, 0), 1)

        currentReading = ProcessedReading(
            rawReading: reading,
            calibratedReading: calibrated,
            magnitude: magnitude,
            normalizedValue: normalized
        )

        displayValue = UnitConverter.convert(magnitude, from: .microTesla, to: selectedUnit)
    }

    // MARK: - Public Actions

    func setDisplayMode(_ mode: DisplayMode) {
        displayMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: Keys.displayMode)
    }

    func setUnit(_ unit: EMFUnit) {
        selectedUnit = unit
        if let reading = currentReading {
            displayValue = UnitConverter.convert(reading.magnitude, from: .microTesla, to: unit)
        }
        UserDefaults.standard.set(unit.rawValue, forKey: Keys.unit)
    }

    func toggleSound() {
        soundEnabled.toggle()
        audioService.isEnabled = soundEnabled
        UserDefaults.standard.set(soundEnabled, forKey: Keys.soundEnabled)
    }

    func calibrate() {
        guard let reading = magnetometerService.currentReading else { return }

        calibrationData = CalibrationData.from(reading: reading)
        isCalibrated = true

        let defaults = UserDefaults.standard
        defaults.set(calibrationData.offsetX, forKey: Keys.calibrationX)
        defaults.set(calibrationData.offsetY, forKey: Keys.calibrationY)
        defaults.set(calibrationData.offsetZ, forKey: Keys.calibrationZ)
        defaults.set(calibrationData.timestamp, forKey: Keys.calibrationTimestamp)
    }

    func resetCalibration() {
        calibrationData = .none
        isCalibrated = false

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.calibrationX)
        defaults.removeObject(forKey: Keys.calibrationY)
        defaults.removeObject(forKey: Keys.calibrationZ)
        defaults.removeObject(forKey: Keys.calibrationTimestamp)
    }

    func setTheme(_ theme: String) {
        self.theme = theme
        UserDefaults.standard.set(theme, forKey: Keys.theme)
    }

    func start() {
        magnetometerService.start()
    }

    func stop() {
        magnetometerService.stop()
    }

    deinit {
        displayLink?.invalidate()
    }
}

// Extension for Float UserDefaults
extension UserDefaults {
    func float(forKey key: String) -> Float {
        Float(double(forKey: key))
    }
}
