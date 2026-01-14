# EMF Meter App

A cross-platform electromagnetic field (EMF) meter app for iOS and Android that transforms your smartphone into an EMF detector using the device's built-in magnetometer.

## Features

- **Dual Display Modes**: Switch between classic analog Geiger counter style and digital LCD calculator display
- **Real-time Measurement**: Continuous EMF readings using device magnetometer
- **Realistic Physics**: Analog needle with spring-damper physics for authentic meter movement
- **Audio Feedback**: Geiger counter click sounds that increase with EMF intensity
- **Multiple Units**: Support for milliGauss (mG), microTesla (µT), and Gauss (G)
- **Calibration**: Zero calibration for accurate relative measurements
- **Dark Mode**: Classic scientific instrument aesthetics in both light and dark themes

## Project Structure

```
emf-meter-app/
├── docs/
│   ├── PRD.md                    # Product Requirements Document
│   └── ENGINEERING_DESIGN.md     # Engineering Design Document
├── shared/                       # Kotlin Multiplatform shared module
│   └── src/
│       └── commonMain/kotlin/com/emfmeter/
│           ├── domain/           # Domain models
│           ├── data/             # Business logic
│           └── util/             # Utilities
├── android/                      # Android app (Kotlin/Compose)
│   └── app/src/main/
│       ├── kotlin/com/emfmeter/
│       │   ├── ui/               # Compose UI
│       │   ├── viewmodel/        # ViewModels
│       │   ├── service/          # Platform services
│       │   └── repository/       # Data persistence
│       └── res/                  # Android resources
└── ios/                          # iOS app (Swift/SwiftUI)
    └── EMFMeter/
        └── Sources/
            ├── Models/           # Swift models
            ├── Views/            # SwiftUI views
            ├── Components/       # Reusable components
            ├── ViewModels/       # ViewModels
            ├── Services/         # Platform services
            └── Theme/            # Colors and styling
```

## Requirements

### Android
- Android Studio Hedgehog (2023.1.1) or later
- JDK 17
- Android SDK 34
- Minimum SDK: 26 (Android 8.0)

### iOS
- Xcode 15.0 or later
- iOS 15.0+
- Swift 5.9

## Building

### Android

```bash
cd emf-meter-app
./gradlew :android:app:assembleDebug
```

### iOS

1. Install XcodeGen (optional, for generating project):
   ```bash
   brew install xcodegen
   ```

2. Generate Xcode project:
   ```bash
   cd ios
   xcodegen generate
   ```

3. Open in Xcode:
   ```bash
   open EMFMeter.xcodeproj
   ```

4. Or create the project manually in Xcode and add the source files.

## Audio Resources

Both platforms require a Geiger counter click sound effect. Add a short (50-100ms) click sound file:

- **Android**: `android/app/src/main/res/raw/geiger_click.mp3`
- **iOS**: `ios/EMFMeter/Resources/geiger_click.mp3`

Free sound effects available from:
- [Freesound.org](https://freesound.org)
- [Pixabay](https://pixabay.com/sound-effects/)
- [Zapsplat](https://www.zapsplat.com)

## Architecture

The app follows a clean architecture pattern with shared business logic:

- **Domain Layer**: Core models (EMFReading, EMFUnit, CalibrationData)
- **Data Layer**: EMFProcessor, NeedlePhysicsEngine, CalibrationManager
- **Presentation Layer**: Platform-specific UI (Compose/SwiftUI)

### Shared Code (KMP)
- Unit conversion utilities
- Needle physics simulation
- Sound click rate calculation
- Domain models

### Platform-Specific
- Magnetometer access (SensorManager/CoreMotion)
- Audio playback (SoundPool/AVFoundation)
- UI components (Compose/SwiftUI)
- Settings persistence (DataStore/UserDefaults)

## Measurement Range

| Unit | Range |
|------|-------|
| MilliGauss (mG) | 0 - 2000 |
| MicroTesla (µT) | 0 - 200 |
| Gauss (G) | 0 - 2 |

## Disclaimer

This app is for educational and entertainment purposes only. It is not a certified EMF measurement device. Readings depend on device sensor quality and should not be used for safety decisions.

## License

[Add your license here]

## Future Features (V2)

- Data logging with history
- Peak hold and min/max tracking
- Export to CSV/PDF
- Real-time graphs
- Ads for free tier / premium ad-free version
