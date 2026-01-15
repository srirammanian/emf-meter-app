# EMF Meter App - Product Requirements Document

**Version:** 2.0
**Last Updated:** January 2026
**Status:** Draft

---

## 1. Executive Summary

EMF Meter is a mobile application that transforms smartphones into electromagnetic field (EMF) detectors using the device's built-in magnetometer. The app features a classic analog Geiger counter-style meter with authentic vintage aesthetics, appealing to hobbyists and users seeking a nostalgic scientific instrument experience.

**V2.0** introduces Pro features including session recording, a real-time oscilloscope graph, data export, and session history—available via a one-time in-app purchase.

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

### 5.2 Display Mode

#### 5.2.1 Analog Meter
- **Visual Style:** Vintage 1950s Geiger counter / scientific instrument aesthetic
- **Meter Design:**
  - Circular gauge with thick black bezel
  - Cream/ivory aged face with subtle texture
  - Semi-circular arc scale (180 degrees)
  - Scale starting at 0 on the left, maximum on the right
  - Vintage-style numbering and tick marks
  - Blue arc band for scale markings
  - "EMF FIELD INTENSITY" header text
  - Center badge with decorative brass corner screws
- **Needle Physics:**
  - Realistic inertia and damping
  - Slight overshoot on rapid changes
  - Natural "jumpy" behavior mimicking real analog meters
- **Visual Elements:**
  - Thick 3D bezel with depth effect
  - Aged ivory face with radial gradient
  - Black mechanical pointer needle
  - Dome-style pivot with highlight

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
│  [Settings]   EMF SCOPE    [?]  │
│─────────────────────────────────│
│                                 │
│     ┌─────────────────────┐     │
│     │   VINTAGE ANALOG    │     │
│     │      METER          │     │
│     │   [REC]             │     │
│     └─────────────────────┘     │
│                                 │
│     ┌─────────────────────┐     │
│     │   OSCILLOSCOPE      │     │  ← Pro Feature
│     │   (Live Graph)      │     │
│     └─────────────────────┘     │
│                                 │
│  [🔊 Sound]    [⚖ Calibrate]    │
│                                 │
└─────────────────────────────────┘
```

### 6.2 Navigation
- **Single Screen App:** No complex navigation required
- **Settings:** Modal/sheet presentation
- **History:** Accessible from Settings (Pro feature)

### 6.3 Settings Screen
- Unit selection (mG / µT / G)
- Theme selection (Light / Dark / System)
- Sound toggle
- Calibration management
- **Recording History** (Pro feature)
- Background recording duration setting (Pro feature)
- About / Credits
- Rate App link
- Privacy Policy link
- **Restore Purchases**

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

## 8. Pro Features (V2)

### 8.1 Session Recording

| Requirement | Description |
|-------------|-------------|
| Trigger | Manual start/stop via dedicated record button |
| Record Button | Large red button next to analog dial, built-in vintage look with depressed/pushable styling |
| Visual Feedback | Button shows pressed state while recording; recording indicator on screen |
| Data Captured | Timestamp + X/Y/Z readings + magnitude at sensor sample rate (30Hz) |
| Background Recording | Continues when app is backgrounded |
| Background Duration | Default 1 hour, user-configurable up to 3 hours in Settings |
| Storage | Local device storage only |
| Session Limit | Unlimited sessions |
| Deletion | Manual delete only (no auto-cleanup) |

### 8.2 Session Metadata

| Field | Description |
|-------|-------------|
| Session ID | Unique identifier (UUID) |
| Start Time | Timestamp when recording began |
| End Time | Timestamp when recording ended |
| Duration | Calculated from start/end |
| Reading Count | Number of data points captured |
| Name | User-editable session name (optional) |
| Notes | User-editable notes field (optional) |
| Min/Max/Avg | Calculated statistics for the session |

### 8.3 Live Oscilloscope Graph

| Requirement | Description |
|-------------|-------------|
| Visual Style | 1950s CRT oscilloscope aesthetic |
| Position | Below analog dial, above control panel |
| Display Window | Last 30 seconds of readings visible |
| Scrolling | Drag horizontally to scroll back through session history |
| CRT Effects | Green phosphor glow, scan lines, slight blur |
| Grid | Oscilloscope-style graticule/grid lines |
| Y-Axis | EMF magnitude (0 to max range) |
| X-Axis | Time (scrollable) |
| Update Rate | Real-time at display refresh rate (60Hz) |

### 8.4 Session History

| Requirement | Description |
|-------------|-------------|
| Access | Button in Settings screen |
| List View | Simple list showing session date, duration, and name |
| Sorting | Most recent first |
| Selection | Tap to view session details |
| Detail View | Full session info with option to edit name/notes |
| Playback | View recorded data in oscilloscope graph |
| Delete | Swipe to delete individual sessions |
| Bulk Delete | Option to delete all sessions |

### 8.5 Data Export

| Requirement | Description |
|-------------|-------------|
| Format | CSV (Comma-Separated Values) |
| Columns | Timestamp, X, Y, Z, Magnitude, Unit |
| Header Row | Column names included |
| Filename | `EMF_Session_YYYY-MM-DD_HHMMSS.csv` |
| Sharing | iOS system share sheet |
| Export From | Session detail view |

### 8.6 Record Button Design

```
┌──────────────────────────────────────┐
│                                      │
│    ┌────────────────────────┐        │
│    │     ANALOG METER       │        │
│    │                        │   ●    │  ← Red REC button
│    │                        │  REC   │    (large, depressed look)
│    │                        │        │
│    └────────────────────────┘        │
│                                      │
│    ┌────────────────────────┐        │
│    │    OSCILLOSCOPE        │        │
│    └────────────────────────┘        │
│                                      │
└──────────────────────────────────────┘
```

---

## 9. Monetization Strategy (V2)

### 9.1 Free Tier
- Full analog meter functionality
- Sound feedback (Geiger clicks)
- Calibration
- Unit switching
- Theme support
- **No advertisements**

### 9.2 Pro Tier (One-Time Purchase: $2.99)

| Feature | Free | Pro |
|---------|------|-----|
| Analog Meter | ✓ | ✓ |
| Sound Feedback | ✓ | ✓ |
| Calibration | ✓ | ✓ |
| Unit Selection | ✓ | ✓ |
| Themes | ✓ | ✓ |
| Oscilloscope Graph | ✗ | ✓ |
| Session Recording | ✗ | ✓ |
| Session History | ✗ | ✓ |
| Data Export (CSV) | ✗ | ✓ |
| Background Recording | ✗ | ✓ |

### 9.3 Purchase Implementation

| Requirement | Description |
|-------------|-------------|
| Framework | StoreKit 2 (iOS 15+) |
| Product Type | Non-consumable (one-time purchase) |
| Product ID | `com.emfmeter.pro` |
| Price | $2.99 USD |
| Restore Purchases | Available in Settings |
| Free Trial | Promotional offer support via StoreKit 2 |
| Paywall Type | Hard paywall (Pro features locked until purchase) |

### 9.4 Upgrade Prompt

| Trigger | Behavior |
|---------|----------|
| Tap Record Button (free user) | Show upgrade modal |
| Tap Oscilloscope area (free user) | Show upgrade modal |
| Tap History in Settings (free user) | Show upgrade modal |

**Upgrade Modal Content:**
- Feature preview with screenshots/animations
- List of Pro features
- Price display ($2.99)
- "Upgrade to Pro" button
- "Restore Purchases" link
- Close/dismiss option

---

## 10. Success Metrics

| Metric | Target |
|--------|--------|
| App Store Rating | 4.0+ stars |
| Crash-free Rate | 99.5%+ |
| Daily Active Users | Track growth |
| Session Duration | 2+ minutes average |
| Pro Conversion Rate | 5%+ of active users |
| Pro Revenue | Track monthly |
| Recording Sessions/User | Track engagement |
| Export Usage | Track feature adoption |

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
