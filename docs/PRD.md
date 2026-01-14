# EMF Meter App - Product Requirements Document

**Version:** 1.0
**Last Updated:** January 2026
**Status:** Draft

---

## 1. Executive Summary

EMF Meter is a cross-platform mobile application that transforms smartphones into electromagnetic field (EMF) detectors using the device's built-in magnetometer. The app features two distinct visualization modes: a classic analog Geiger counter-style meter and a digital calculator-style display, appealing to both hobbyists and users seeking a nostalgic scientific instrument experience.

---

## 2. Product Vision

Create an authentic, visually compelling EMF measurement tool that combines the charm of vintage scientific instruments with modern mobile technology. The app will serve users interested in EMF detection for educational, hobbyist, paranormal investigation, or general curiosity purposes.

---

## 3. Target Audience

- **Hobbyists & DIY Enthusiasts:** Users interested in exploring electromagnetic fields in their environment
- **Paranormal Investigators:** Community seeking EMF detection tools
- **Educational Users:** Students and teachers demonstrating electromagnetic principles
- **Curious Consumers:** General public interested in understanding EMF exposure from devices

---

## 4. Platform Requirements

### 4.1 Supported Platforms
| Platform | Language/Framework | Minimum Version |
|----------|-------------------|-----------------|
| iOS | Swift / SwiftUI | iOS 15.0+ |
| Android | Kotlin / Jetpack Compose | Android 8.0 (API 26)+ |

### 4.2 Device Requirements
- Built-in magnetometer/magnetic field sensor (required)
- Speaker for audio feedback (optional, degrades gracefully)

---

## 5. Core Features (V1)

### 5.1 EMF Measurement
| Feature | Description |
|---------|-------------|
| Real-time Sensing | Continuous reading from device magnetometer |
| Magnitude Display | Combined magnitude of X, Y, Z axis readings |
| Update Rate | Minimum 30Hz sampling, 60Hz display refresh |
| Accuracy | Limited by device sensor capabilities |

### 5.2 Display Modes

#### 5.2.1 Analog Mode
- **Visual Style:** Classic Geiger counter / scientific instrument aesthetic
- **Meter Design:**
  - Semi-circular arc scale (approximately 90-120 degrees)
  - Scale starting at 0 on the left, maximum on the right
  - Vintage-style numbering and tick marks
  - Rotating needle/arrow indicator
- **Needle Physics:**
  - Realistic inertia and damping
  - Slight overshoot on rapid changes
  - Natural "jumpy" behavior mimicking real analog meters
- **Visual Elements:**
  - Aged/textured bezel
  - Glass reflection effect (subtle)
  - Worn label aesthetics

#### 5.2.2 Digital Mode
- **Visual Style:** Classic LCD calculator display
- **Display:**
  - 7-segment style digits
  - Large, easily readable numbers
  - Unit indicator
- **Visual Elements:**
  - LCD segment "shadow" effect (showing inactive segments)
  - Slight LCD pixel texture
  - Retro digital frame/housing

### 5.3 Unit System
| Unit | Symbol | Conversion | Default |
|------|--------|------------|---------|
| MilliGauss | mG | 1 mG = 0.1 µT | Yes |
| MicroTesla | µT | Base unit | No |
| Gauss | G | 1 G = 100 µT | No |

### 5.4 Measurement Range
| Range | Value |
|-------|-------|
| Minimum | 0 mG |
| Maximum | 2000 mG (200 µT) |
| Resolution | 0.1 mG |

*Note: Most smartphone magnetometers have a range of ±2000 µT, but typical environmental EMF readings are well under 200 µT.*

### 5.5 Calibration
- **Zero Calibration:** User-initiated baseline zeroing
- **Process:**
  1. User moves device away from EMF sources
  2. Taps calibrate button
  3. Current reading becomes new zero offset
- **Persistence:** Calibration offset saved between sessions
- **Reset:** Option to clear calibration and return to raw readings

### 5.6 Audio Feedback
- **Geiger Counter Sound Effect:**
  - Click rate proportional to EMF intensity
  - Low EMF: Slow, sporadic clicks
  - High EMF: Rapid clicking
- **Controls:**
  - Toggle on/off
  - Volume control (uses system volume)
- **Behavior:** Only active in Analog mode by default

### 5.7 Theme Support
| Theme | Description |
|-------|-------------|
| Light Mode | Classic beige/cream instrument panel |
| Dark Mode | Dark gray/black instrument panel with illuminated elements |
| System | Follows device system setting |

---

## 6. User Interface

### 6.1 Main Screen Layout
```
┌─────────────────────────────────┐
│  [Settings]     EMF METER  [?]  │
│─────────────────────────────────│
│                                 │
│     ┌─────────────────────┐     │
│     │                     │     │
│     │   METER DISPLAY     │     │
│     │   (Analog/Digital)  │     │
│     │                     │     │
│     └─────────────────────┘     │
│                                 │
│         123.4 mG                │
│                                 │
│  [Analog] ──●── [Digital]       │
│                                 │
│  [🔊 Sound]    [⚖ Calibrate]    │
│                                 │
└─────────────────────────────────┘
```

### 6.2 Navigation
- **Single Screen App:** No complex navigation required
- **Settings:** Modal/sheet presentation
- **Mode Toggle:** Segmented control or animated switch

### 6.3 Settings Screen
- Unit selection (mG / µT / G)
- Theme selection (Light / Dark / System)
- Sound toggle
- Calibration management
- About / Credits
- Rate App link
- Privacy Policy link

---

## 7. Technical Constraints

### 7.1 Sensor Limitations
- Accuracy depends on device magnetometer quality
- Readings affected by device's own electromagnetic interference
- Temperature can affect sensor accuracy
- Not a certified measurement device

### 7.2 Disclaimers Required
- App is for entertainment/educational purposes
- Not a certified EMF measurement device
- Readings should not be used for safety decisions
- Accuracy varies by device

---

## 8. Future Features (V2)

| Feature | Description | Monetization |
|---------|-------------|--------------|
| Data Logging | Record readings over time | Premium |
| Peak Hold | Display maximum reading since reset | Premium |
| Min/Max Tracking | Show range of readings | Premium |
| Export Data | CSV/PDF export of logs | Premium |
| Graphs | Real-time graph of readings | Premium |
| Ad Removal | Remove advertisements | Premium |
| Widgets | Home screen widgets | Premium |

---

## 9. Monetization Strategy (V2)

### 9.1 Free Tier
- Full V1 functionality
- Advertisement supported (banner ads)
- Standard features

### 9.2 Premium Tier
- All V2 features
- Ad-free experience
- One-time purchase or subscription TBD

---

## 10. Success Metrics

| Metric | Target |
|--------|--------|
| App Store Rating | 4.0+ stars |
| Crash-free Rate | 99.5%+ |
| Daily Active Users | Track growth |
| Session Duration | 2+ minutes average |
| Premium Conversion | Track for V2 |

---

## 11. Launch Requirements

### 11.1 App Store Assets
- App icon (multiple sizes)
- Screenshots (all device sizes)
- App preview video (optional)
- Description and keywords
- Privacy policy URL
- Support URL

### 11.2 Legal
- Privacy policy (no personal data collected in V1)
- Terms of service
- Disclaimer about measurement accuracy

---

## 12. Timeline

| Milestone | Deliverable |
|-----------|-------------|
| Phase 1 | PRD & Design Documents |
| Phase 2 | Shared KMP Module Implementation |
| Phase 3 | Android App Implementation |
| Phase 4 | iOS App Implementation |
| Phase 5 | Testing & Polish |
| Phase 6 | App Store Submission |

---

## 13. Appendix

### 13.1 EMF Reference Values
| Source | Typical Reading |
|--------|-----------------|
| Earth's Magnetic Field | 250-650 mG (25-65 µT) |
| Near a smartphone | 50-200 mG |
| Near a microwave (operating) | 100-300 mG |
| Near power lines | 10-200 mG |
| Near a refrigerator | 5-50 mG |

### 13.2 Competitive Analysis
Similar apps exist but often lack:
- High-quality vintage aesthetics
- Realistic needle physics
- Sound effects
- Cross-platform consistency

Our differentiators:
- Premium visual design
- Authentic analog meter simulation
- Satisfying audio feedback
- Native performance on both platforms
