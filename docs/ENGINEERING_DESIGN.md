# EMF Meter App - Engineering Design Document

**Version:** 2.0
**Last Updated:** January 2026
**Status:** Draft

---

## 1. Overview

This document describes the technical architecture and implementation details for the EMF Meter application. The app is built natively for iOS using SwiftUI, with Android support via Kotlin/Jetpack Compose.

**V2.0** adds Pro features (iOS only): session recording, oscilloscope graph, session history, and CSV export—monetized via StoreKit 2 in-app purchase.

---

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
├─────────────────────────────┬───────────────────────────────────┤
│      iOS (SwiftUI)          │        Android (Compose)          │
│  ┌───────────────────────┐  │  ┌───────────────────────────┐    │
│  │ Views / Components    │  │  │ Composables / Screens     │    │
│  │ - MainView            │  │  │ - AnalogMeterScreen       │    │
│  │ - AnalogMeterView     │  │  │ - SettingsScreen          │    │
│  │ - OscilloscopeView ◆  │  │  │                           │    │
│  │ - RecordButtonView ◆  │  │  │                           │    │
│  │ - SettingsView        │  │  │                           │    │
│  │ - SessionHistoryView ◆│  │  │                           │    │
│  │ - UpgradePromptView ◆ │  │  │                           │    │
│  └───────────────────────┘  │  └───────────────────────────┘    │
│  ┌───────────────────────┐  │  ┌───────────────────────────┐    │
│  │ ViewModels            │  │  │ ViewModels                │    │
│  │ - EMFViewModel        │  │  │ - EMFViewModel            │    │
│  │ - RecordingViewModel ◆│  │  │                           │    │
│  │ - StoreViewModel ◆    │  │  │                           │    │
│  └───────────────────────┘  │  └───────────────────────────┘    │
├─────────────────────────────┴───────────────────────────────────┤
│                       DOMAIN LAYER                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Models                                                      │ │
│  │ - EMFReading                                                │ │
│  │ - EMFUnit (enum)                                            │ │
│  │ - CalibrationData                                           │ │
│  │ - RecordingSession ◆                                        │ │
│  │ - SessionMetadata ◆                                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Business Logic                                              │ │
│  │ - NeedlePhysicsEngine                                       │ │
│  │ - UnitConverter                                             │ │
│  │ - MeterConfig                                               │ │
│  └────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                     PLATFORM/SERVICE LAYER                       │
├─────────────────────────────┬───────────────────────────────────┤
│      iOS                    │        Android                     │
│  ┌───────────────────────┐  │  ┌───────────────────────────┐    │
│  │ MagnetometerService   │  │  │ MagnetometerService       │    │
│  │ (CoreMotion)          │  │  │ (SensorManager)           │    │
│  └───────────────────────┘  │  └───────────────────────────┘    │
│  ┌───────────────────────┐  │  ┌───────────────────────────┐    │
│  │ AudioService          │  │  │ AudioService              │    │
│  │ (AVFoundation)        │  │  │ (SoundPool)               │    │
│  └───────────────────────┘  │  └───────────────────────────┘    │
│  ┌───────────────────────┐  │  ┌───────────────────────────┐    │
│  │ RecordingService ◆    │  │  │ SettingsStorage           │    │
│  │ (Background tasks)    │  │  │ (DataStore)               │    │
│  └───────────────────────┘  │  └───────────────────────────┘    │
│  ┌───────────────────────┐  │                                   │
│  │ SessionStorage ◆      │  │                                   │
│  │ (File + UserDefaults) │  │                                   │
│  └───────────────────────┘  │                                   │
│  ┌───────────────────────┐  │                                   │
│  │ StoreKitManager ◆     │  │                                   │
│  │ (StoreKit 2)          │  │                                   │
│  └───────────────────────┘  │                                   │
│  ┌───────────────────────┐  │                                   │
│  │ ExportService ◆       │  │                                   │
│  │ (CSV generation)      │  │                                   │
│  └───────────────────────┘  │                                   │
└─────────────────────────────┴───────────────────────────────────┘

◆ = New in V2.0 (Pro features, iOS only)
```

### 2.2 Code Sharing Strategy

| Layer | Shared (KMP) | Platform-Specific |
|-------|--------------|-------------------|
| Domain Models | 100% | 0% |
| Business Logic | 100% | 0% |
| Unit Conversion | 100% | 0% |
| Physics Engine | 100% | 0% |
| Sensor Access | 0% | 100% |
| Audio Playback | 0% | 100% |
| UI/Views | 0% | 100% |
| ViewModels | ~30% shared logic | ~70% platform-specific |

---

## 3. Shared Module (KMP)

### 3.1 Project Structure

```
shared/
├── build.gradle.kts
└── src/
    ├── commonMain/
    │   └── kotlin/
    │       └── com/emfmeter/
    │           ├── domain/
    │           │   ├── EMFReading.kt
    │           │   ├── EMFUnit.kt
    │           │   ├── CalibrationData.kt
    │           │   └── MeterConfig.kt
    │           ├── data/
    │           │   ├── EMFProcessor.kt
    │           │   ├── CalibrationManager.kt
    │           │   └── NeedlePhysicsEngine.kt
    │           └── util/
    │               ├── UnitConverter.kt
    │               └── MathUtils.kt
    └── commonTest/
        └── kotlin/
            └── com/emfmeter/
                └── ... (unit tests)
```

### 3.2 Domain Models

#### 3.2.1 EMFReading
```kotlin
data class EMFReading(
    val x: Float,           // Raw X-axis value in microtesla
    val y: Float,           // Raw Y-axis value in microtesla
    val z: Float,           // Raw Z-axis value in microtesla
    val timestamp: Long     // Unix timestamp in milliseconds
) {
    val magnitude: Float
        get() = sqrt(x * x + y * y + z * z)
}
```

#### 3.2.2 EMFUnit
```kotlin
enum class EMFUnit(
    val symbol: String,
    val displayName: String,
    val fromMicroTesla: (Float) -> Float,
    val toMicroTesla: (Float) -> Float
) {
    MICRO_TESLA("µT", "MicroTesla", { it }, { it }),
    MILLI_GAUSS("mG", "MilliGauss", { it * 10f }, { it / 10f }),
    GAUSS("G", "Gauss", { it / 100f }, { it * 100f })
}
```

#### 3.2.3 CalibrationData
```kotlin
data class CalibrationData(
    val offsetX: Float = 0f,
    val offsetY: Float = 0f,
    val offsetZ: Float = 0f,
    val timestamp: Long = 0
) {
    fun apply(reading: EMFReading): EMFReading {
        return EMFReading(
            x = reading.x - offsetX,
            y = reading.y - offsetY,
            z = reading.z - offsetZ,
            timestamp = reading.timestamp
        )
    }
}
```

#### 3.2.4 MeterConfig
```kotlin
object MeterConfig {
    const val MIN_VALUE_UT = 0f          // Minimum reading (µT)
    const val MAX_VALUE_UT = 200f        // Maximum reading (µT)
    const val SAMPLE_RATE_HZ = 30        // Sensor sampling rate
    const val DISPLAY_REFRESH_HZ = 60    // Display update rate

    // Analog meter arc configuration
    const val ARC_START_ANGLE = 225f     // Degrees from 3 o'clock
    const val ARC_SWEEP_ANGLE = 90f      // Total arc sweep

    // Default unit
    val DEFAULT_UNIT = EMFUnit.MILLI_GAUSS
}
```

### 3.3 Business Logic

#### 3.3.1 EMFProcessor
```kotlin
class EMFProcessor(
    private val calibrationManager: CalibrationManager
) {
    fun process(reading: EMFReading): ProcessedReading {
        val calibrated = calibrationManager.apply(reading)
        return ProcessedReading(
            rawReading = reading,
            calibratedReading = calibrated,
            magnitude = calibrated.magnitude,
            normalizedValue = (calibrated.magnitude / MeterConfig.MAX_VALUE_UT)
                .coerceIn(0f, 1f)
        )
    }
}

data class ProcessedReading(
    val rawReading: EMFReading,
    val calibratedReading: EMFReading,
    val magnitude: Float,
    val normalizedValue: Float  // 0.0 to 1.0 for meter display
)
```

#### 3.3.2 NeedlePhysicsEngine
```kotlin
class NeedlePhysicsEngine(
    private val dampingFactor: Float = 0.7f,
    private val springConstant: Float = 120f,
    private val mass: Float = 1f
) {
    private var currentPosition: Float = 0f
    private var velocity: Float = 0f

    fun update(targetPosition: Float, deltaTime: Float): Float {
        // Spring-damper system for realistic needle movement
        val displacement = targetPosition - currentPosition
        val springForce = springConstant * displacement
        val dampingForce = dampingFactor * velocity
        val acceleration = (springForce - dampingForce) / mass

        velocity += acceleration * deltaTime
        currentPosition += velocity * deltaTime

        // Add slight noise for "jumpy" effect
        val noise = if (abs(velocity) > 0.01f) {
            (Random.nextFloat() - 0.5f) * 0.02f * abs(velocity)
        } else 0f

        return (currentPosition + noise).coerceIn(0f, 1f)
    }

    fun reset() {
        currentPosition = 0f
        velocity = 0f
    }
}
```

#### 3.3.3 Sound Click Rate Calculator
```kotlin
object SoundClickCalculator {
    // Returns clicks per second based on normalized EMF value (0-1)
    fun calculateClickRate(normalizedValue: Float): Float {
        return when {
            normalizedValue < 0.05f -> 0f
            normalizedValue < 0.2f -> 1f + normalizedValue * 10f
            normalizedValue < 0.5f -> 3f + normalizedValue * 20f
            normalizedValue < 0.8f -> 10f + normalizedValue * 30f
            else -> 30f + normalizedValue * 50f
        }
    }

    // Returns interval in milliseconds between clicks
    fun calculateClickInterval(normalizedValue: Float): Long {
        val rate = calculateClickRate(normalizedValue)
        return if (rate > 0) (1000f / rate).toLong() else Long.MAX_VALUE
    }
}
```

### 3.4 Unit Converter
```kotlin
object UnitConverter {
    fun convert(value: Float, from: EMFUnit, to: EMFUnit): Float {
        val microTesla = from.toMicroTesla(value)
        return to.fromMicroTesla(microTesla)
    }

    fun formatValue(value: Float, unit: EMFUnit): String {
        return when (unit) {
            EMFUnit.MICRO_TESLA -> "%.1f".format(value)
            EMFUnit.MILLI_GAUSS -> "%.1f".format(value)
            EMFUnit.GAUSS -> "%.3f".format(value)
        }
    }
}
```

---

## 4. Android Implementation

### 4.1 Project Structure

```
android/
├── app/
│   ├── build.gradle.kts
│   └── src/
│       └── main/
│           ├── kotlin/com/emfmeter/
│           │   ├── EMFMeterApplication.kt
│           │   ├── MainActivity.kt
│           │   ├── ui/
│           │   │   ├── theme/
│           │   │   │   ├── Theme.kt
│           │   │   │   ├── Color.kt
│           │   │   │   └── Typography.kt
│           │   │   ├── screens/
│           │   │   │   ├── MainScreen.kt
│           │   │   │   └── SettingsScreen.kt
│           │   │   └── components/
│           │   │       ├── AnalogMeter.kt
│           │   │       ├── DigitalDisplay.kt
│           │   │       ├── ModeToggle.kt
│           │   │       └── ControlButtons.kt
│           │   ├── viewmodel/
│           │   │   └── EMFViewModel.kt
│           │   └── service/
│           │       ├── MagnetometerService.kt
│           │       └── AudioService.kt
│           ├── res/
│           │   ├── drawable/
│           │   ├── values/
│           │   │   ├── colors.xml
│           │   │   ├── strings.xml
│           │   │   └── themes.xml
│           │   └── raw/
│           │       └── geiger_click.mp3
│           └── AndroidManifest.xml
├── build.gradle.kts
└── settings.gradle.kts
```

### 4.2 Magnetometer Service

```kotlin
class MagnetometerService(context: Context) {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val magnetometer = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

    private val _readings = MutableSharedFlow<EMFReading>(replay = 1)
    val readings: SharedFlow<EMFReading> = _readings.asSharedFlow()

    val isAvailable: Boolean = magnetometer != null

    private val sensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            val reading = EMFReading(
                x = event.values[0],
                y = event.values[1],
                z = event.values[2],
                timestamp = System.currentTimeMillis()
            )
            _readings.tryEmit(reading)
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    fun start() {
        magnetometer?.let {
            sensorManager.registerListener(
                sensorListener,
                it,
                SensorManager.SENSOR_DELAY_GAME  // ~20ms, ~50Hz
            )
        }
    }

    fun stop() {
        sensorManager.unregisterListener(sensorListener)
    }
}
```

### 4.3 Audio Service

```kotlin
class AudioService(context: Context) {
    private val soundPool: SoundPool = SoundPool.Builder()
        .setMaxStreams(4)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()

    private val clickSoundId: Int = soundPool.load(context, R.raw.geiger_click, 1)
    private var isEnabled: Boolean = true
    private var lastClickTime: Long = 0

    fun playClickIfNeeded(normalizedValue: Float) {
        if (!isEnabled) return

        val interval = SoundClickCalculator.calculateClickInterval(normalizedValue)
        val now = System.currentTimeMillis()

        if (now - lastClickTime >= interval) {
            soundPool.play(clickSoundId, 0.5f, 0.5f, 1, 0, 1.0f)
            lastClickTime = now
        }
    }

    fun setEnabled(enabled: Boolean) {
        isEnabled = enabled
    }

    fun release() {
        soundPool.release()
    }
}
```

### 4.4 ViewModel

```kotlin
@HiltViewModel
class EMFViewModel @Inject constructor(
    private val magnetometerService: MagnetometerService,
    private val audioService: AudioService,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val emfProcessor = EMFProcessor(CalibrationManager())
    private val needlePhysics = NeedlePhysicsEngine()

    private val _uiState = MutableStateFlow(EMFUiState())
    val uiState: StateFlow<EMFUiState> = _uiState.asStateFlow()

    init {
        observeReadings()
        loadSettings()
    }

    private fun observeReadings() {
        viewModelScope.launch {
            magnetometerService.readings.collect { reading ->
                val processed = emfProcessor.process(reading)
                val needlePosition = needlePhysics.update(
                    processed.normalizedValue,
                    deltaTime = 1f / MeterConfig.DISPLAY_REFRESH_HZ
                )

                _uiState.update { state ->
                    state.copy(
                        currentReading = processed,
                        needlePosition = needlePosition,
                        displayValue = UnitConverter.convert(
                            processed.magnitude,
                            EMFUnit.MICRO_TESLA,
                            state.selectedUnit
                        )
                    )
                }

                if (state.value.soundEnabled && state.value.displayMode == DisplayMode.ANALOG) {
                    audioService.playClickIfNeeded(processed.normalizedValue)
                }
            }
        }
    }

    fun setDisplayMode(mode: DisplayMode) {
        _uiState.update { it.copy(displayMode = mode) }
    }

    fun setUnit(unit: EMFUnit) {
        _uiState.update { it.copy(selectedUnit = unit) }
        viewModelScope.launch { settingsRepository.saveUnit(unit) }
    }

    fun calibrate() {
        val current = _uiState.value.currentReading?.rawReading ?: return
        emfProcessor.calibrationManager.calibrate(current)
        viewModelScope.launch { settingsRepository.saveCalibration(...) }
    }

    fun toggleSound() {
        val newState = !_uiState.value.soundEnabled
        _uiState.update { it.copy(soundEnabled = newState) }
        audioService.setEnabled(newState)
    }

    fun onStart() {
        magnetometerService.start()
    }

    fun onStop() {
        magnetometerService.stop()
    }
}

data class EMFUiState(
    val currentReading: ProcessedReading? = null,
    val needlePosition: Float = 0f,
    val displayValue: Float = 0f,
    val displayMode: DisplayMode = DisplayMode.ANALOG,
    val selectedUnit: EMFUnit = EMFUnit.MILLI_GAUSS,
    val soundEnabled: Boolean = true,
    val isCalibrated: Boolean = false,
    val sensorAvailable: Boolean = true
)

enum class DisplayMode { ANALOG, DIGITAL }
```

### 4.5 Analog Meter Composable

```kotlin
@Composable
fun AnalogMeter(
    needlePosition: Float,  // 0.0 to 1.0
    modifier: Modifier = Modifier
) {
    Canvas(modifier = modifier.aspectRatio(1.2f)) {
        val centerX = size.width / 2
        val centerY = size.height * 0.85f
        val radius = size.width * 0.4f

        // Draw bezel
        drawArc(
            color = Color(0xFF2C2C2C),
            startAngle = 225f,
            sweepAngle = 90f,
            useCenter = false,
            style = Stroke(width = 20f),
            topLeft = Offset(centerX - radius, centerY - radius),
            size = Size(radius * 2, radius * 2)
        )

        // Draw scale markings
        for (i in 0..10) {
            val angle = Math.toRadians((225 - i * 9).toDouble())
            val innerRadius = radius * 0.85f
            val outerRadius = radius * 0.95f

            drawLine(
                color = Color.White,
                start = Offset(
                    centerX + (innerRadius * cos(angle)).toFloat(),
                    centerY - (innerRadius * sin(angle)).toFloat()
                ),
                end = Offset(
                    centerX + (outerRadius * cos(angle)).toFloat(),
                    centerY - (outerRadius * sin(angle)).toFloat()
                ),
                strokeWidth = if (i % 5 == 0) 3f else 1.5f
            )
        }

        // Draw needle
        val needleAngle = Math.toRadians((225 - needlePosition * 90).toDouble())
        val needleLength = radius * 0.75f

        drawLine(
            color = Color.Red,
            start = Offset(centerX, centerY),
            end = Offset(
                centerX + (needleLength * cos(needleAngle)).toFloat(),
                centerY - (needleLength * sin(needleAngle)).toFloat()
            ),
            strokeWidth = 4f,
            cap = StrokeCap.Round
        )

        // Draw center pivot
        drawCircle(
            color = Color(0xFF8B0000),
            radius = 12f,
            center = Offset(centerX, centerY)
        )
    }
}
```

### 4.6 Digital Display Composable

```kotlin
@Composable
fun DigitalDisplay(
    value: Float,
    unit: EMFUnit,
    modifier: Modifier = Modifier
) {
    val formattedValue = UnitConverter.formatValue(value, unit)

    Box(
        modifier = modifier
            .background(
                color = Color(0xFF1A3A1A),
                shape = RoundedCornerShape(8.dp)
            )
            .border(
                width = 4.dp,
                color = Color(0xFF333333),
                shape = RoundedCornerShape(8.dp)
            )
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.Bottom
        ) {
            // LCD-style digits
            Text(
                text = formattedValue,
                fontFamily = FontFamily(Font(R.font.digital_7)),
                fontSize = 72.sp,
                color = Color(0xFF00FF00),
                letterSpacing = 4.sp
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = unit.symbol,
                fontSize = 24.sp,
                color = Color(0xFF00FF00).copy(alpha = 0.8f)
            )
        }
    }
}
```

---

## 5. iOS Implementation

### 5.1 Project Structure

```
ios/
└── EMFMeter/
    ├── EMFMeter.xcodeproj
    ├── Sources/
    │   ├── EMFMeterApp.swift
    │   ├── Views/
    │   │   ├── MainView.swift
    │   │   ├── SettingsView.swift
    │   │   └── ContentView.swift
    │   ├── Components/
    │   │   ├── AnalogMeterView.swift
    │   │   ├── DigitalDisplayView.swift
    │   │   ├── ModeToggleView.swift
    │   │   └── ControlButtonsView.swift
    │   ├── ViewModels/
    │   │   └── EMFViewModel.swift
    │   ├── Services/
    │   │   ├── MagnetometerService.swift
    │   │   └── AudioService.swift
    │   ├── Theme/
    │   │   ├── Colors.swift
    │   │   └── Fonts.swift
    │   └── Models/
    │       └── SharedModels.swift (bridged from KMP or reimplemented)
    └── Resources/
        ├── Assets.xcassets
        └── Sounds/
            └── geiger_click.mp3
```

### 5.2 Magnetometer Service

```swift
import CoreMotion
import Combine

class MagnetometerService: ObservableObject {
    private let motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()

    @Published var currentReading: EMFReading?

    var isAvailable: Bool {
        motionManager.isMagnetometerAvailable
    }

    func start() {
        guard motionManager.isMagnetometerAvailable else { return }

        motionManager.magnetometerUpdateInterval = 1.0 / 30.0  // 30 Hz
        motionManager.startMagnetometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }

            self?.currentReading = EMFReading(
                x: Float(data.magneticField.x),
                y: Float(data.magneticField.y),
                z: Float(data.magneticField.z),
                timestamp: Int64(Date().timeIntervalSince1970 * 1000)
            )
        }
    }

    func stop() {
        motionManager.stopMagnetometerUpdates()
    }
}
```

### 5.3 Audio Service

```swift
import AVFoundation

class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var lastClickTime: Date = .distantPast
    @Published var isEnabled: Bool = true

    init() {
        setupAudio()
    }

    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "geiger_click", withExtension: "mp3") else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.5
        } catch {
            print("Audio setup failed: \(error)")
        }
    }

    func playClickIfNeeded(normalizedValue: Float) {
        guard isEnabled else { return }

        let interval = SoundClickCalculator.calculateClickInterval(normalizedValue: normalizedValue)
        let now = Date()

        if now.timeIntervalSince(lastClickTime) * 1000 >= Double(interval) {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
            lastClickTime = now
        }
    }
}
```

### 5.4 ViewModel

```swift
import SwiftUI
import Combine

class EMFViewModel: ObservableObject {
    private let magnetometerService = MagnetometerService()
    private let audioService = AudioService()
    private var emfProcessor: EMFProcessor
    private var needlePhysics = NeedlePhysicsEngine()
    private var cancellables = Set<AnyCancellable>()
    private var displayLink: CADisplayLink?

    @Published var needlePosition: Float = 0
    @Published var displayValue: Float = 0
    @Published var displayMode: DisplayMode = .analog
    @Published var selectedUnit: EMFUnit = .milliGauss
    @Published var soundEnabled: Bool = true
    @Published var isCalibrated: Bool = false
    @Published var sensorAvailable: Bool = true

    @AppStorage("calibrationOffsetX") private var calibrationOffsetX: Double = 0
    @AppStorage("calibrationOffsetY") private var calibrationOffsetY: Double = 0
    @AppStorage("calibrationOffsetZ") private var calibrationOffsetZ: Double = 0

    private var currentReading: ProcessedReading?

    init() {
        let calibration = CalibrationData(
            offsetX: Float(calibrationOffsetX),
            offsetY: Float(calibrationOffsetY),
            offsetZ: Float(calibrationOffsetZ)
        )
        emfProcessor = EMFProcessor(calibrationManager: CalibrationManager(initialCalibration: calibration))
        sensorAvailable = magnetometerService.isAvailable

        setupBindings()
        setupDisplayLink()
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
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60)
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateNeedle() {
        guard let reading = currentReading else { return }
        needlePosition = needlePhysics.update(
            targetPosition: reading.normalizedValue,
            deltaTime: 1.0 / 60.0
        )

        if soundEnabled && displayMode == .analog {
            audioService.playClickIfNeeded(normalizedValue: reading.normalizedValue)
        }
    }

    private func processReading(_ reading: EMFReading) {
        let processed = emfProcessor.process(reading: reading)
        currentReading = processed
        displayValue = UnitConverter.convert(
            value: processed.magnitude,
            from: .microTesla,
            to: selectedUnit
        )
    }

    func calibrate() {
        guard let reading = magnetometerService.currentReading else { return }
        emfProcessor.calibrationManager.calibrate(reading: reading)

        calibrationOffsetX = Double(reading.x)
        calibrationOffsetY = Double(reading.y)
        calibrationOffsetZ = Double(reading.z)
        isCalibrated = true
    }

    func resetCalibration() {
        emfProcessor.calibrationManager.reset()
        calibrationOffsetX = 0
        calibrationOffsetY = 0
        calibrationOffsetZ = 0
        isCalibrated = false
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

enum DisplayMode {
    case analog
    case digital
}
```

### 5.5 Analog Meter View

```swift
import SwiftUI

struct AnalogMeterView: View {
    let needlePosition: Float  // 0.0 to 1.0

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height * 0.85
            let radius = size.width * 0.4

            // Draw bezel arc
            let arcPath = Path { path in
                path.addArc(
                    center: CGPoint(x: centerX, y: centerY),
                    radius: radius,
                    startAngle: .degrees(225),
                    endAngle: .degrees(315),
                    clockwise: false
                )
            }
            context.stroke(arcPath, with: .color(.gray), lineWidth: 20)

            // Draw scale markings
            for i in 0...10 {
                let angle = Double(225 - i * 9) * .pi / 180
                let innerRadius = radius * 0.85
                let outerRadius = radius * 0.95

                let start = CGPoint(
                    x: centerX + innerRadius * cos(angle),
                    y: centerY - innerRadius * sin(angle)
                )
                let end = CGPoint(
                    x: centerX + outerRadius * cos(angle),
                    y: centerY - outerRadius * sin(angle)
                )

                var tickPath = Path()
                tickPath.move(to: start)
                tickPath.addLine(to: end)

                context.stroke(
                    tickPath,
                    with: .color(.white),
                    lineWidth: i % 5 == 0 ? 3 : 1.5
                )
            }

            // Draw needle
            let needleAngle = Double(225 - Double(needlePosition) * 90) * .pi / 180
            let needleLength = radius * 0.75

            var needlePath = Path()
            needlePath.move(to: CGPoint(x: centerX, y: centerY))
            needlePath.addLine(to: CGPoint(
                x: centerX + needleLength * cos(needleAngle),
                y: centerY - needleLength * sin(needleAngle)
            ))

            context.stroke(needlePath, with: .color(.red), lineWidth: 4)

            // Draw center pivot
            context.fill(
                Path(ellipseIn: CGRect(
                    x: centerX - 12,
                    y: centerY - 12,
                    width: 24,
                    height: 24
                )),
                with: .color(Color(red: 0.55, green: 0, blue: 0))
            )
        }
        .aspectRatio(1.2, contentMode: .fit)
    }
}
```

### 5.6 Digital Display View

```swift
import SwiftUI

struct DigitalDisplayView: View {
    let value: Float
    let unit: EMFUnit

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.1, green: 0.23, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 4)
                )

            HStack(alignment: .bottom, spacing: 8) {
                Text(UnitConverter.formatValue(value: value, unit: unit))
                    .font(.custom("Digital-7", size: 72))
                    .foregroundColor(Color(red: 0, green: 1, blue: 0))
                    .monospacedDigit()

                Text(unit.symbol)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(red: 0, green: 1, blue: 0).opacity(0.8))
            }
            .padding(24)
        }
    }
}
```

---

## 6. Data Persistence

### 6.1 Settings to Persist
| Setting | Android | iOS |
|---------|---------|-----|
| Selected Unit | DataStore | UserDefaults |
| Theme | DataStore | UserDefaults |
| Sound Enabled | DataStore | UserDefaults |
| Calibration Offsets | DataStore | UserDefaults |

### 6.2 Android DataStore

```kotlin
@Singleton
class SettingsRepository @Inject constructor(
    private val dataStore: DataStore<Preferences>
) {
    val unit = dataStore.data.map { it[UNIT_KEY] ?: EMFUnit.MILLI_GAUSS.name }
    val soundEnabled = dataStore.data.map { it[SOUND_KEY] ?: true }
    val calibrationX = dataStore.data.map { it[CAL_X_KEY] ?: 0f }
    // ... etc

    suspend fun saveUnit(unit: EMFUnit) {
        dataStore.edit { it[UNIT_KEY] = unit.name }
    }

    companion object {
        val UNIT_KEY = stringPreferencesKey("selected_unit")
        val SOUND_KEY = booleanPreferencesKey("sound_enabled")
        val CAL_X_KEY = floatPreferencesKey("calibration_x")
        // ... etc
    }
}
```

---

## 7. Theming

### 7.1 Color Palette

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | #F5F5DC (Beige) | #1A1A1A (Near Black) |
| Bezel | #8B8B7A (Olive Gray) | #2C2C2C (Dark Gray) |
| Meter Face | #FFFEF0 (Cream) | #252525 (Charcoal) |
| Scale Text | #333333 (Dark Gray) | #E0E0E0 (Light Gray) |
| Needle | #CC0000 (Red) | #FF3333 (Bright Red) |
| Digital BG | #1A3A1A (Dark Green) | #0A1A0A (Darker Green) |
| Digital Text | #00FF00 (Lime) | #00FF00 (Lime) |
| Accent | #8B4513 (Saddle Brown) | #CD853F (Peru) |

### 7.2 Typography
- **Digital Display:** Digital-7 font (or similar LCD-style font)
- **Labels:** System font with vintage styling
- **Scale Numbers:** Condensed, technical font

---

## 8. Testing Strategy

### 8.1 Unit Tests (Shared Module)
- EMFProcessor calculations
- UnitConverter accuracy
- NeedlePhysicsEngine behavior
- CalibrationManager offset application
- SoundClickCalculator rate calculations

### 8.2 Integration Tests
- Sensor data flow to ViewModel
- Settings persistence and restoration
- Calibration workflow

### 8.3 UI Tests
- Mode switching
- Unit changing
- Calibration button functionality
- Settings navigation

### 8.4 Manual Testing
- Real device magnetometer readings
- Sound timing and behavior
- Needle animation smoothness
- Theme switching

---

## 9. Build & Deployment

### 9.1 Android
```
./gradlew :android:app:assembleRelease
./gradlew :android:app:bundleRelease  # For Play Store
```

### 9.2 iOS
- Archive via Xcode
- Distribute to App Store Connect

### 9.3 CI/CD Considerations
- GitHub Actions for build validation
- Automated testing on PR
- Beta distribution via TestFlight / Firebase App Distribution

---

## 10. Dependencies

### 10.1 Android
| Dependency | Purpose |
|------------|---------|
| Jetpack Compose | UI framework |
| Hilt | Dependency injection |
| DataStore | Settings persistence |
| Lifecycle | ViewModel, lifecycle-aware components |

### 10.2 iOS
| Dependency | Purpose |
|------------|---------|
| SwiftUI | UI framework |
| CoreMotion | Magnetometer access |
| AVFoundation | Audio playback |
| Combine | Reactive programming |

### 10.3 Shared (KMP)
| Dependency | Purpose |
|------------|---------|
| Kotlin Stdlib | Core Kotlin |
| Kotlinx Coroutines | Async programming |

---

## 11. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Magnetometer unavailable | Graceful degradation with user message |
| Sensor noise | Low-pass filtering in EMFProcessor |
| Performance issues with animations | Use hardware-accelerated Canvas/Metal |
| Audio latency | Pre-load sounds, use low-latency audio APIs |
| Battery drain | Reduce sample rate when app backgrounded |

---

## 12. V2 Pro Features Architecture (iOS)

### 12.1 New Data Models

#### 12.1.1 RecordingSession
```swift
struct RecordingSession: Identifiable, Codable {
    let id: UUID
    var name: String?
    var notes: String?
    let startTime: Date
    var endTime: Date?
    var readings: [TimestampedReading]

    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }

    var statistics: SessionStatistics {
        SessionStatistics(readings: readings)
    }
}

struct TimestampedReading: Codable {
    let timestamp: TimeInterval  // Seconds since session start
    let x: Float
    let y: Float
    let z: Float
    let magnitude: Float
}

struct SessionStatistics: Codable {
    let minMagnitude: Float
    let maxMagnitude: Float
    let avgMagnitude: Float
    let readingCount: Int

    init(readings: [TimestampedReading]) {
        guard !readings.isEmpty else {
            self.minMagnitude = 0
            self.maxMagnitude = 0
            self.avgMagnitude = 0
            self.readingCount = 0
            return
        }
        self.minMagnitude = readings.map(\.magnitude).min() ?? 0
        self.maxMagnitude = readings.map(\.magnitude).max() ?? 0
        self.avgMagnitude = readings.map(\.magnitude).reduce(0, +) / Float(readings.count)
        self.readingCount = readings.count
    }
}
```

#### 12.1.2 SessionMetadata (for list view, lightweight)
```swift
struct SessionMetadata: Identifiable, Codable {
    let id: UUID
    var name: String?
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let readingCount: Int
    let minMagnitude: Float
    let maxMagnitude: Float
    let avgMagnitude: Float
}
```

### 12.2 RecordingService

Handles session recording with background support.

```swift
import Foundation
import Combine
import BackgroundTasks

class RecordingService: ObservableObject {
    // MARK: - Published State
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var currentSession: RecordingSession?
    @Published private(set) var recordingDuration: TimeInterval = 0

    // MARK: - Configuration
    @AppStorage("maxBackgroundDuration") var maxBackgroundDuration: TimeInterval = 3600 // 1 hour

    // MARK: - Private
    private var readings: [TimestampedReading] = []
    private var sessionStartTime: Date?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var durationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Recording Control

    func startRecording() {
        guard !isRecording else { return }

        sessionStartTime = Date()
        readings = []
        isRecording = true
        recordingDuration = 0

        currentSession = RecordingSession(
            id: UUID(),
            name: nil,
            notes: nil,
            startTime: sessionStartTime!,
            endTime: nil,
            readings: []
        )

        startDurationTimer()
        registerBackgroundTask()
    }

    func stopRecording() -> RecordingSession? {
        guard isRecording, var session = currentSession else { return nil }

        isRecording = false
        session.endTime = Date()
        session.readings = readings

        durationTimer?.invalidate()
        endBackgroundTask()

        currentSession = nil
        readings = []

        return session
    }

    func addReading(_ reading: EMFReading) {
        guard isRecording, let startTime = sessionStartTime else { return }

        let timestamped = TimestampedReading(
            timestamp: Date().timeIntervalSince(startTime),
            x: reading.x,
            y: reading.y,
            z: reading.z,
            magnitude: reading.magnitude
        )
        readings.append(timestamped)
    }

    // MARK: - Background Support

    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.handleBackgroundExpiration()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    private func handleBackgroundExpiration() {
        // Auto-stop recording when background time expires
        if isRecording && recordingDuration >= maxBackgroundDuration {
            _ = stopRecording()
        }
        endBackgroundTask()
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.sessionStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)

            // Auto-stop if background duration exceeded
            if self.recordingDuration >= self.maxBackgroundDuration {
                _ = self.stopRecording()
            }
        }
    }
}
```

### 12.3 SessionStorage

Manages persistence of recording sessions to local storage.

```swift
import Foundation

class SessionStorage: ObservableObject {
    private let sessionsDirectory: URL
    private let metadataFile: URL

    @Published private(set) var sessions: [SessionMetadata] = []

    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        sessionsDirectory = documentsPath.appendingPathComponent("EMFSessions", isDirectory: true)
        metadataFile = sessionsDirectory.appendingPathComponent("metadata.json")

        createDirectoryIfNeeded()
        loadMetadata()
    }

    // MARK: - Public API

    func save(_ session: RecordingSession) throws {
        // Save full session data
        let sessionFile = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(session)
        try data.write(to: sessionFile)

        // Update metadata list
        let metadata = SessionMetadata(
            id: session.id,
            name: session.name,
            startTime: session.startTime,
            endTime: session.endTime ?? Date(),
            duration: session.duration,
            readingCount: session.readings.count,
            minMagnitude: session.statistics.minMagnitude,
            maxMagnitude: session.statistics.maxMagnitude,
            avgMagnitude: session.statistics.avgMagnitude
        )
        sessions.insert(metadata, at: 0)
        saveMetadata()
    }

    func load(sessionId: UUID) throws -> RecordingSession {
        let sessionFile = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        let data = try Data(contentsOf: sessionFile)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(RecordingSession.self, from: data)
    }

    func delete(sessionId: UUID) throws {
        let sessionFile = sessionsDirectory.appendingPathComponent("\(sessionId.uuidString).json")
        try FileManager.default.removeItem(at: sessionFile)
        sessions.removeAll { $0.id == sessionId }
        saveMetadata()
    }

    func deleteAll() throws {
        for session in sessions {
            let sessionFile = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
            try? FileManager.default.removeItem(at: sessionFile)
        }
        sessions.removeAll()
        saveMetadata()
    }

    func updateMetadata(sessionId: UUID, name: String?, notes: String?) throws {
        // Load, update, and save session
        var session = try load(sessionId: sessionId)
        session.name = name
        session.notes = notes
        try save(session)
    }

    // MARK: - Private

    private func createDirectoryIfNeeded() {
        try? FileManager.default.createDirectory(at: sessionsDirectory, withIntermediateDirectories: true)
    }

    private func loadMetadata() {
        guard let data = try? Data(contentsOf: metadataFile) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        sessions = (try? decoder.decode([SessionMetadata].self, from: data)) ?? []
    }

    private func saveMetadata() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: metadataFile)
    }
}
```

### 12.4 StoreKitManager

Handles in-app purchases using StoreKit 2.

```swift
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let proProductId = "com.emfmeter.pro"

    @Published private(set) var isProUnlocked: Bool = false
    @Published private(set) var proProduct: Product?
    @Published private(set) var purchaseState: PurchaseState = .idle

    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(Error)
    }

    private var updateListenerTask: Task<Void, Error>?

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public API

    func purchase() async throws {
        guard let product = proProduct else { return }

        purchaseState = .purchasing

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            isProUnlocked = true
            purchaseState = .purchased

        case .userCancelled:
            purchaseState = .idle

        case .pending:
            purchaseState = .idle

        @unknown default:
            purchaseState = .idle
        }
    }

    func restorePurchases() async {
        await updatePurchaseStatus()
    }

    // MARK: - Private

    private func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.proProductId])
            proProduct = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    private func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.proProductId {
                    isProUnlocked = true
                    return
                }
            }
        }
        isProUnlocked = false
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == Self.proProductId {
                        await MainActor.run {
                            self.isProUnlocked = true
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let item):
            return item
        }
    }
}

enum StoreError: Error {
    case verificationFailed
}
```

### 12.5 ExportService

Generates CSV files for session export.

```swift
import Foundation
import UniformTypeIdentifiers

class ExportService {

    func generateCSV(from session: RecordingSession, unit: EMFUnit) -> URL? {
        var csvContent = "Timestamp (s),X (\(unit.symbol)),Y (\(unit.symbol)),Z (\(unit.symbol)),Magnitude (\(unit.symbol))\n"

        for reading in session.readings {
            let x = UnitConverter.convert(reading.x, from: .microTesla, to: unit)
            let y = UnitConverter.convert(reading.y, from: .microTesla, to: unit)
            let z = UnitConverter.convert(reading.z, from: .microTesla, to: unit)
            let magnitude = UnitConverter.convert(reading.magnitude, from: .microTesla, to: unit)

            csvContent += String(format: "%.3f,%.2f,%.2f,%.2f,%.2f\n",
                                 reading.timestamp, x, y, z, magnitude)
        }

        // Create temp file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let filename = "EMF_Session_\(dateFormatter.string(from: session.startTime)).csv"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
}
```

### 12.6 OscilloscopeView

SwiftUI view rendering the vintage CRT-style oscilloscope graph.

```swift
import SwiftUI

struct OscilloscopeView: View {
    let readings: [TimestampedReading]
    let maxValue: Float
    let visibleDuration: TimeInterval = 30  // 30 seconds visible

    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // CRT Background
                crtBackground

                // Grid lines (graticule)
                graticule(in: geometry.size)

                // Waveform
                waveform(in: geometry.size)

                // Phosphor glow overlay
                phosphorGlow

                // Scan lines
                scanLines(in: geometry.size)

                // Bezel frame
                bezelFrame
            }
            .gesture(dragGesture)
        }
        .aspectRatio(2.5, contentMode: .fit)
    }

    // MARK: - CRT Effects

    private var crtBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                RadialGradient(
                    colors: [Color(hex: "0A2010"), Color(hex: "051008")],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
    }

    private func graticule(in size: CGSize) -> some View {
        Canvas { context, size in
            let gridColor = Color(hex: "1A4020").opacity(0.6)

            // Vertical lines (time divisions)
            for i in 0...10 {
                let x = size.width * CGFloat(i) / 10
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }

            // Horizontal lines (magnitude divisions)
            for i in 0...4 {
                let y = size.height * CGFloat(i) / 4
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
    }

    private func waveform(in size: CGSize) -> some View {
        Canvas { context, size in
            guard readings.count > 1 else { return }

            let totalOffset = scrollOffset + dragOffset
            let pixelsPerSecond = size.width / visibleDuration

            var path = Path()
            var firstPoint = true

            for reading in readings {
                let x = size.width - (reading.timestamp * pixelsPerSecond) + totalOffset
                guard x >= -10 && x <= size.width + 10 else { continue }

                let normalizedY = CGFloat(reading.magnitude / maxValue).clamped(to: 0...1)
                let y = size.height * (1 - normalizedY)

                if firstPoint {
                    path.move(to: CGPoint(x: x, y: y))
                    firstPoint = false
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            // Phosphor green with glow
            context.stroke(path, with: .color(Color(hex: "00FF00")), lineWidth: 2)
        }
        .blur(radius: 0.5)  // Subtle phosphor blur
    }

    private var phosphorGlow: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: "00FF00").opacity(0.03))
            .blur(radius: 20)
    }

    private func scanLines(in size: CGSize) -> some View {
        Canvas { context, size in
            for y in stride(from: 0, to: size.height, by: 2) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.black.opacity(0.1)), lineWidth: 1)
            }
        }
    }

    private var bezelFrame: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    colors: [Color(hex: "2A2A2A"), Color(hex: "1A1A1A")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 6
            )
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                scrollOffset += value.translation.width
                scrollOffset = max(0, scrollOffset)  // Can't scroll past present
            }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
```

### 12.7 RecordButtonView

Vintage-styled recording button positioned next to the analog meter.

```swift
import SwiftUI

struct RecordButtonView: View {
    @Binding var isRecording: Bool
    let isProUser: Bool
    let onTap: () -> Void
    let onUpgradeNeeded: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: handleTap) {
            ZStack {
                // Button housing (metallic rim)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A4A4A"), Color(hex: "2A2A2A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                // Inner depression
                Circle()
                    .fill(Color(hex: "1A1A1A"))
                    .frame(width: 50, height: 50)
                    .offset(y: isPressed ? 2 : 0)

                // Red button surface
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isRecording
                                ? [Color(hex: "FF0000"), Color(hex: "AA0000")]
                                : [Color(hex: "CC0000"), Color(hex: "880000")],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 44, height: 44)
                    .offset(y: isPressed ? 2 : 0)
                    .shadow(color: .black.opacity(0.5), radius: isPressed ? 1 : 3, y: isPressed ? 1 : 2)

                // Recording indicator light
                if isRecording {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .offset(y: isPressed ? 2 : 0)
                        .opacity(blinkOpacity)
                }

                // REC label
                Text("REC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .offset(y: 32)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint(isProUser ? "" : "Requires Pro upgrade")
    }

    @State private var blinkOpacity: Double = 1.0

    private func handleTap() {
        if isProUser {
            onTap()
        } else {
            onUpgradeNeeded()
        }
    }
}
```

### 12.8 UpgradePromptView

Modal view shown when free users attempt to access Pro features.

```swift
import SwiftUI

struct UpgradePromptView: View {
    @ObservedObject var storeManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "waveform.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)

                Text("Upgrade to Pro")
                    .font(.title.bold())

                Text("Unlock advanced features")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Feature list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "record.circle", title: "Session Recording", description: "Record and save EMF readings")
                FeatureRow(icon: "waveform", title: "Oscilloscope Graph", description: "Real-time vintage CRT display")
                FeatureRow(icon: "clock.arrow.circlepath", title: "Session History", description: "Browse and manage recordings")
                FeatureRow(icon: "square.and.arrow.up", title: "CSV Export", description: "Share data for analysis")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Spacer()

            // Price and purchase button
            VStack(spacing: 12) {
                if let product = storeManager.proProduct {
                    Text(product.displayPrice)
                        .font(.title2.bold())

                    Text("One-time purchase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Button(action: { Task { try? await storeManager.purchase() } }) {
                    HStack {
                        if case .purchasing = storeManager.purchaseState {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Upgrade to Pro")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(storeManager.purchaseState == .purchasing)

                Button("Restore Purchases") {
                    Task { await storeManager.restorePurchases() }
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .onChange(of: storeManager.isProUnlocked) { unlocked in
            if unlocked { dismiss() }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
```

### 12.9 Updated iOS Project Structure

```
ios/EMFMeter/Sources/
├── EMFMeterApp.swift
├── Models/
│   ├── EMFModels.swift
│   ├── RecordingSession.swift          ◆ NEW
│   └── SessionMetadata.swift            ◆ NEW
├── ViewModels/
│   ├── EMFViewModel.swift
│   ├── RecordingViewModel.swift         ◆ NEW
│   └── StoreViewModel.swift             ◆ NEW
├── Views/
│   ├── MainView.swift
│   ├── SettingsView.swift
│   ├── SafetyInfoView.swift
│   ├── SessionHistoryView.swift         ◆ NEW
│   ├── SessionDetailView.swift          ◆ NEW
│   └── UpgradePromptView.swift          ◆ NEW
├── Components/
│   ├── AnalogMeterView.swift
│   ├── OscilloscopeView.swift           ◆ NEW
│   ├── RecordButtonView.swift           ◆ NEW
│   ├── ControlPanelView.swift
│   └── ...
├── Services/
│   ├── MagnetometerService.swift
│   ├── AudioService.swift
│   ├── RecordingService.swift           ◆ NEW
│   ├── SessionStorage.swift             ◆ NEW
│   ├── StoreKitManager.swift            ◆ NEW
│   └── ExportService.swift              ◆ NEW
└── Theme/
    └── Colors.swift

◆ = New in V2.0
```

### 12.10 StoreKit Configuration

Create `Products.storekit` configuration file for testing:

```xml
{
  "products": [
    {
      "displayPrice": "2.99",
      "familyShareable": false,
      "internalID": "com.emfmeter.pro",
      "localizations": [
        {
          "description": "Unlock recording, oscilloscope, history, and export features",
          "displayName": "EMF Scope Pro",
          "locale": "en_US"
        }
      ],
      "productID": "com.emfmeter.pro",
      "referenceName": "Pro Upgrade",
      "type": "NonConsumable"
    }
  ],
  "settings": {}
}
```

### 12.11 Background Recording Configuration

Add to `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.emfmeter.recording</string>
</array>
```

---

## 13. Future Considerations (V3+)

- iCloud sync for sessions
- Apple Watch companion app
- Home screen widgets
- AR mode showing EMF visualization
- Map overlay showing readings by location
- Additional export formats (JSON, PDF reports)
- Android Pro features parity
