import SwiftUI
import Combine

// MARK: - UserDefaults Keys

private enum EMFViewModelKeys {
    static let unit = "selectedUnit"
    static let soundEnabled = "soundEnabled"
    static let displayMode = "displayMode"
    static let theme = "theme"
    static let calibrationX = "calibrationX"
    static let calibrationY = "calibrationY"
    static let calibrationZ = "calibrationZ"
    static let calibrationTimestamp = "calibrationTimestamp"
    static let hasLaunchedBefore = "hasLaunchedBefore"
}

/// ViewModel for the EMF Meter.
@MainActor
class EMFViewModel: ObservableObject {
    // Services - using type-erased wrapper for protocol
    private let magnetometerService: AnyMagnetometerService
    private let audioService = AudioService()
    private let needlePhysics = NeedlePhysicsEngine()

    // Calibration
    private var calibrationData: CalibrationData = .none
    private var needsAutoCalibration: Bool = false

    // Display link for animation
    private var displayLink: CADisplayLink?
    private var cancellables = Set<AnyCancellable>()

    // Published state
    @Published var needlePosition: Float = 0
    @Published var displayValue: Float = 0
    @Published var displayMode: DisplayMode = .analog
    @Published var selectedUnit: EMFUnit = .microTesla
    @Published var soundEnabled: Bool = true
    @Published var isCalibrated: Bool = false
    @Published var sensorAvailable: Bool = true
    @Published var showSettings: Bool = false
    @Published var theme: String = "system"

    /// Current raw reading (exposed for recording service)
    @Published private(set) var currentReading: EMFReading?

    // Current processed reading (internal)
    private var processedReading: ProcessedReading?

    /// Initialize with automatic service selection (mock on simulator, real on device).
    /// Also supports UI testing launch arguments for different scenarios.
    convenience init() {
        let service = MagnetometerServiceFactory.create()
        self.init(magnetometerService: AnyMagnetometerService(service))
    }

    /// Initialize with a specific magnetometer service (for testing/customization).
    init<T: MagnetometerServiceProtocol>(magnetometerService: T) {
        self.magnetometerService = AnyMagnetometerService(magnetometerService)
        loadSettings()
        setupBindings()
        setupDisplayLink()
        sensorAvailable = self.magnetometerService.isAvailable
    }

    /// Initialize with a type-erased service directly.
    init(magnetometerService: AnyMagnetometerService) {
        self.magnetometerService = magnetometerService
        loadSettings()
        setupBindings()
        setupDisplayLink()
        sensorAvailable = magnetometerService.isAvailable
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard

        // Load unit
        if let unitString = defaults.string(forKey: EMFViewModelKeys.unit),
           let unit = EMFUnit(rawValue: unitString) {
            selectedUnit = unit
        }

        // Load sound
        soundEnabled = defaults.object(forKey: EMFViewModelKeys.soundEnabled) as? Bool ?? true
        audioService.isEnabled = soundEnabled

        // Load display mode
        if let modeString = defaults.string(forKey: EMFViewModelKeys.displayMode),
           let mode = DisplayMode(rawValue: modeString) {
            displayMode = mode
        }

        // Load theme
        theme = defaults.string(forKey: EMFViewModelKeys.theme) ?? "system"

        // Load calibration
        let calibrationTimestamp = defaults.double(forKey: EMFViewModelKeys.calibrationTimestamp)
        if calibrationTimestamp > 0 {
            calibrationData = CalibrationData(
                offsetX: defaults.float(forKey: EMFViewModelKeys.calibrationX),
                offsetY: defaults.float(forKey: EMFViewModelKeys.calibrationY),
                offsetZ: defaults.float(forKey: EMFViewModelKeys.calibrationZ),
                timestamp: calibrationTimestamp
            )
            isCalibrated = true
        }

        // Check if this is the first launch - if so, auto-calibrate once we get a reading
        let hasLaunchedBefore = defaults.bool(forKey: EMFViewModelKeys.hasLaunchedBefore)
        if !hasLaunchedBefore {
            needsAutoCalibration = true
            defaults.set(true, forKey: EMFViewModelKeys.hasLaunchedBefore)
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
        guard let reading = processedReading else { return }

        let newPosition = needlePhysics.update(
            targetPosition: reading.normalizedValue,
            deltaTime: 1.0 / Float(MeterConfig.displayRefreshHz)
        )
        needlePosition = newPosition

        if soundEnabled {
            audioService.playClickIfNeeded(normalizedValue: reading.normalizedValue)
        }
    }

    private func processReading(_ reading: EMFReading) {
        // Auto-calibrate on first launch once we have a valid reading
        if needsAutoCalibration {
            calibrationData = CalibrationData.from(reading: reading)
            isCalibrated = true
            needsAutoCalibration = false

            // Persist the auto-calibration
            let defaults = UserDefaults.standard
            defaults.set(calibrationData.offsetX, forKey: EMFViewModelKeys.calibrationX)
            defaults.set(calibrationData.offsetY, forKey: EMFViewModelKeys.calibrationY)
            defaults.set(calibrationData.offsetZ, forKey: EMFViewModelKeys.calibrationZ)
            defaults.set(calibrationData.timestamp, forKey: EMFViewModelKeys.calibrationTimestamp)
        }

        let calibrated = calibrationData.apply(to: reading)
        let magnitude = calibrated.magnitude
        let normalized = min(max(magnitude / MeterConfig.maxValueUT, 0), 1)

        currentReading = calibrated  // Expose calibrated reading for recording/oscilloscope
        processedReading = ProcessedReading(
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
        UserDefaults.standard.set(mode.rawValue, forKey: EMFViewModelKeys.displayMode)
    }

    func setUnit(_ unit: EMFUnit) {
        selectedUnit = unit
        if let reading = processedReading {
            displayValue = UnitConverter.convert(reading.magnitude, from: .microTesla, to: unit)
        }
        UserDefaults.standard.set(unit.rawValue, forKey: EMFViewModelKeys.unit)
    }

    func toggleSound() {
        audioService.playSwitch()
        soundEnabled.toggle()
        audioService.isEnabled = soundEnabled
        UserDefaults.standard.set(soundEnabled, forKey: EMFViewModelKeys.soundEnabled)
    }

    func calibrate() {
        audioService.playPushButton()
        guard let reading = magnetometerService.currentReading else { return }

        calibrationData = CalibrationData.from(reading: reading)
        isCalibrated = true

        let defaults = UserDefaults.standard
        defaults.set(calibrationData.offsetX, forKey: EMFViewModelKeys.calibrationX)
        defaults.set(calibrationData.offsetY, forKey: EMFViewModelKeys.calibrationY)
        defaults.set(calibrationData.offsetZ, forKey: EMFViewModelKeys.calibrationZ)
        defaults.set(calibrationData.timestamp, forKey: EMFViewModelKeys.calibrationTimestamp)
    }

    func resetCalibration() {
        calibrationData = .none
        isCalibrated = false

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: EMFViewModelKeys.calibrationX)
        defaults.removeObject(forKey: EMFViewModelKeys.calibrationY)
        defaults.removeObject(forKey: EMFViewModelKeys.calibrationZ)
        defaults.removeObject(forKey: EMFViewModelKeys.calibrationTimestamp)
    }

    func setTheme(_ theme: String) {
        self.theme = theme
        UserDefaults.standard.set(theme, forKey: EMFViewModelKeys.theme)
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
