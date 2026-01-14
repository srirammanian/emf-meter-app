import SwiftUI

/// Risk level for health hazard indicator
enum RiskLevel {
    case safe
    case caution
    case danger

    var color: Color {
        switch self {
        case .safe: return Color(hex: "4CAF50")      // Green
        case .caution: return Color(hex: "FFC107")  // Amber/Yellow
        case .danger: return Color(hex: "F44336")   // Red
        }
    }

    var glowColor: Color {
        switch self {
        case .safe: return Color(hex: "81C784")
        case .caution: return Color(hex: "FFD54F")
        case .danger: return Color(hex: "E57373")
        }
    }

    var label: String {
        switch self {
        case .safe: return "SAFE"
        case .caution: return "CAUTION"
        case .danger: return "DANGER"
        }
    }
}

/// Main view for the EMF Meter app - styled as vintage scientific equipment.
struct MainView: View {
    @StateObject private var viewModel = EMFViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showSafetyInfo = false

    /// Calculate risk level based on needle position (0-1 normalized)
    private func riskLevel(for position: Float) -> RiskLevel {
        switch position {
        case 0..<0.2: return .safe       // 0-20% of max (0-40 µT)
        case 0.2..<0.8: return .caution  // 20-80% of max (40-160 µT)
        default: return .danger          // 80-100% of max (160-200 µT)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Skeuomorphic metallic device background
                MetallicDeviceBackground()
                    .ignoresSafeArea()

                if !viewModel.sensorAvailable {
                    SensorUnavailableView()
                } else {
                    VStack(spacing: 0) {
                        // Embossed title plate
                        TitlePlateView()
                            .padding(.top, geometry.safeAreaInsets.top + 16)

                        Spacer()

                        // Analog meter display
                        AnalogMeterView(
                            needlePosition: viewModel.needlePosition,
                            unit: viewModel.selectedUnit,
                            displayValue: viewModel.displayValue
                        )

                        // Health risk indicator with info button
                        HazardIndicatorView(
                            riskLevel: riskLevel(for: viewModel.needlePosition),
                            onInfoTap: { showSafetyInfo = true }
                        )
                        .padding(.top, 16)

                        Spacer()

                        // Vintage control panel
                        VintageControlPanelView(
                            soundEnabled: viewModel.soundEnabled,
                            isCalibrated: viewModel.isCalibrated,
                            onSoundToggle: { viewModel.toggleSound() },
                            onCalibrate: { viewModel.calibrate() },
                            onSettingsClick: { viewModel.showSettings = true }
                        )
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                }

                // Corner rivets
                CornerRivetsView()
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView(
                selectedUnit: viewModel.selectedUnit,
                selectedTheme: viewModel.theme,
                isCalibrated: viewModel.isCalibrated,
                onUnitChange: { viewModel.setUnit($0) },
                onThemeChange: { viewModel.setTheme($0) },
                onResetCalibration: { viewModel.resetCalibration() }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSafetyInfo) {
            SafetyInfoView()
                .presentationDetents([.large])
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

// MARK: - Skeuomorphic Background Components

/// Metallic hammered texture background like vintage equipment
private struct MetallicDeviceBackground: View {
    var body: some View {
        ZStack {
            // Base metal color
            LinearGradient(
                colors: [
                    Color(hex: "7A7A70"),
                    Color(hex: "8A8A80"),
                    Color(hex: "6A6A60"),
                    Color(hex: "7A7A70")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Hammered texture overlay
            Canvas { context, size in
                // Create subtle hammered/brushed metal effect
                for _ in 0..<800 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let width = CGFloat.random(in: 2...8)
                    let height = CGFloat.random(in: 1...3)
                    let opacity = Double.random(in: 0.02...0.08)

                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.white.opacity(opacity))
                    )
                }

                // Add some darker spots for depth
                for _ in 0..<400 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let size = CGFloat.random(in: 1...4)
                    let opacity = Double.random(in: 0.03...0.08)

                    let rect = CGRect(x: x, y: y, width: size, height: size)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.black.opacity(opacity))
                    )
                }
            }

            // Edge darkening for depth
            VStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.3), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)

                Spacer()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
            }

            // Side shadows
            HStack {
                LinearGradient(
                    colors: [Color.black.opacity(0.2), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)

                Spacer()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.15)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)
            }
        }
    }
}

/// Embossed title plate at the top
private struct TitlePlateView: View {
    var body: some View {
        ZStack {
            // Plate background
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "5A5A52"),
                            Color(hex: "4A4A42"),
                            Color(hex: "5A5A52")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 36)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)

            // Inner bevel effect
            RoundedRectangle(cornerRadius: 3)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .frame(width: 198, height: 34)

            // Embossed text
            Text("EMF DETECTOR")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .tracking(3)
                .foregroundColor(Color(hex: "C0C0B0"))
                .shadow(color: .black.opacity(0.8), radius: 0, x: 0, y: 1)
        }
    }
}

/// Vintage jewel indicator lamp for hazard level with info button
private struct HazardIndicatorView: View {
    let riskLevel: RiskLevel
    let onInfoTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            // Jewel indicator lamp
            ZStack {
                // Outer bezel/housing
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4A4A42"),
                                Color(hex: "3A3A32"),
                                Color(hex: "2A2A22")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)

                // Inner ring
                Circle()
                    .stroke(Color(hex: "5A5A52"), lineWidth: 2)
                    .frame(width: 38, height: 38)

                // Recessed socket
                Circle()
                    .fill(Color(hex: "1A1A15"))
                    .frame(width: 32, height: 32)

                // Glowing jewel dome
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                riskLevel.glowColor,
                                riskLevel.color,
                                riskLevel.color.opacity(0.8)
                            ],
                            center: .init(x: 0.35, y: 0.35),
                            startRadius: 0,
                            endRadius: 14
                        )
                    )
                    .frame(width: 26, height: 26)
                    .shadow(color: riskLevel.color.opacity(0.8), radius: 8, x: 0, y: 0)

                // Glass highlight
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .frame(width: 16, height: 10)
                    .offset(x: -2, y: -6)
            }

            // Risk label plate with info button
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "2A2A25"))
                        .frame(width: 70, height: 18)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1A1A15"), Color(hex: "252520")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 66, height: 14)

                    Text(riskLevel.label)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(riskLevel.color)
                        .shadow(color: riskLevel.color.opacity(0.5), radius: 2, x: 0, y: 0)
                }

                // Info button (sized to match label)
                Button(action: onInfoTap) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "3A3A32"))
                            .frame(width: 18, height: 18)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)

                        Circle()
                            .stroke(Color(hex: "4A4A42"), lineWidth: 1)
                            .frame(width: 16, height: 16)

                        Text("i")
                            .font(.system(size: 10, weight: .semibold, design: .serif))
                            .italic()
                            .foregroundColor(Color(hex: "A0A090"))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Corner rivets for the device
private struct CornerRivetsView: View {
    var body: some View {
        GeometryReader { geometry in
            let inset: CGFloat = 20
            let rivetSize: CGFloat = 14

            ZStack {
                // Top left
                RivetView(size: rivetSize)
                    .position(x: inset, y: inset + geometry.safeAreaInsets.top)

                // Top right
                RivetView(size: rivetSize)
                    .position(x: geometry.size.width - inset, y: inset + geometry.safeAreaInsets.top)

                // Bottom left
                RivetView(size: rivetSize)
                    .position(x: inset, y: geometry.size.height - inset)

                // Bottom right
                RivetView(size: rivetSize)
                    .position(x: geometry.size.width - inset, y: geometry.size.height - inset)

                // Additional rivets along edges
                RivetView(size: rivetSize * 0.8)
                    .position(x: geometry.size.width / 2, y: inset + geometry.safeAreaInsets.top)

                RivetView(size: rivetSize * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - inset)
            }
        }
    }
}

/// Single rivet/screw decoration
private struct RivetView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: size, height: size)
                .offset(x: 1, y: 1)

            // Rivet body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "9A9A90"),
                            Color(hex: "6A6A60"),
                            Color(hex: "4A4A40")
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Center indent
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3A3A30"),
                            Color(hex: "5A5A50")
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
        }
    }
}

/// Vintage control panel with toggle switches
private struct VintageControlPanelView: View {
    let soundEnabled: Bool
    let isCalibrated: Bool
    let onSoundToggle: () -> Void
    let onCalibrate: () -> Void
    let onSettingsClick: () -> Void

    var body: some View {
        // Control panel plate
        ZStack {
            // Panel background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "5A5A52"),
                            Color(hex: "4A4A42")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 3)

            // Panel border
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )

            // Controls layout
            HStack(alignment: .top, spacing: 30) {
                // Sound toggle
                VintageToggleSwitchView(
                    label: "AUDIO",
                    isOn: soundEnabled,
                    onColor: Color(hex: "4CAF50"),
                    action: onSoundToggle
                )

                // Calibrate button
                VintagePushButtonView(
                    label: "ZERO",
                    isActive: isCalibrated,
                    action: onCalibrate
                )

                // Settings dial
                VintageDialButtonView(
                    action: onSettingsClick
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 320, height: 115)
    }
}

/// Vintage toggle switch like on old equipment
/// Lever UP = ON, Lever DOWN = OFF
private struct VintageToggleSwitchView: View {
    let label: String
    let isOn: Bool
    let onColor: Color
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Label plate - aligned with other controls
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            // Toggle switch housing
            Button(action: action) {
                ZStack {
                    // Switch housing
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "2A2A25"))
                        .frame(width: 36, height: 50)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

                    // Inner recess
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1A1A15"), Color(hex: "252520")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 30, height: 44)

                    // Indicator lights (top = ON, bottom = OFF)
                    VStack {
                        Circle()
                            .fill(isOn ? onColor : Color(hex: "2A2A20"))
                            .frame(width: 6, height: 6)
                            .shadow(color: isOn ? onColor.opacity(0.8) : .clear, radius: 3)

                        Spacer()

                        Circle()
                            .fill(!isOn ? Color(hex: "C44536") : Color(hex: "2A2A20"))
                            .frame(width: 6, height: 6)
                            .shadow(color: !isOn ? Color(hex: "C44536").opacity(0.6) : .clear, radius: 3)
                    }
                    .frame(height: 38)
                    .padding(.vertical, 3)

                    // Toggle lever - UP when ON, DOWN when OFF
                    VStack(spacing: 0) {
                        if !isOn {
                            Spacer()
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D0D0C0"),
                                            Color(hex: "9A9A8A"),
                                            Color(hex: "6A6A5A")
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 24, height: 18)

                            VStack(spacing: 2) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.2))
                                        .frame(width: 16, height: 1)
                                }
                            }
                        }
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: isOn ? -1 : 1)

                        if isOn {
                            Spacer()
                        }
                    }
                    .frame(width: 30, height: 36)
                    .animation(.easeInOut(duration: 0.12), value: isOn)
                }
            }
            .buttonStyle(.plain)

            // Status indicator to match other controls
            HStack(spacing: 4) {
                Circle()
                    .fill(isOn ? onColor : Color(hex: "C44536"))
                    .frame(width: 6, height: 6)
                    .shadow(color: (isOn ? onColor : Color(hex: "C44536")).opacity(0.6), radius: 3)
                Text(isOn ? "ON" : "OFF")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(isOn ? onColor : Color(hex: "C44536"))
            }
            .frame(height: 10)
        }
    }
}

/// Vintage push button for calibration
private struct VintagePushButtonView: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            // Label plate
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            // Push button
            Button(action: action) {
                ZStack {
                    // Button housing (recessed)
                    Circle()
                        .fill(Color(hex: "2A2A25"))
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

                    // Inner recess
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "1A1A15"), Color(hex: "252520")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 38, height: 38)

                    // Button cap
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "D44536"),
                                    Color(hex: "A43526"),
                                    Color(hex: "842516")
                                ],
                                center: .init(x: 0.35, y: 0.35),
                                startRadius: 0,
                                endRadius: 16
                            )
                        )
                        .frame(width: isPressed ? 28 : 32, height: isPressed ? 28 : 32)
                        .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 2, x: 0, y: isPressed ? 1 : 2)

                    // Button highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: .init(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 10
                            )
                        )
                        .frame(width: 28, height: 28)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                isPressed = pressing
            }, perform: {})

            // Status indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(isActive ? Color(hex: "4CAF50") : Color(hex: "3A3A30"))
                    .frame(width: 6, height: 6)
                    .shadow(color: isActive ? Color(hex: "4CAF50").opacity(0.8) : .clear, radius: 3)
                Text(isActive ? "SET" : "")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(Color(hex: "4CAF50"))
            }
            .frame(height: 10)
        }
    }
}

/// Vintage dial/knob for settings
private struct VintageDialButtonView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Label
            Text("CONFIG")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            // Dial button
            Button(action: action) {
                ZStack {
                    // Dial base
                    Circle()
                        .fill(Color(hex: "2A2A25"))
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

                    // Knob
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "8A8A7A"),
                                    Color(hex: "5A5A4A"),
                                    Color(hex: "3A3A2A")
                                ],
                                center: .init(x: 0.35, y: 0.35),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 36, height: 36)

                    // Knob edge ridges
                    ForEach(0..<12, id: \.self) { i in
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 2, height: 6)
                            .offset(y: -15)
                            .rotationEffect(.degrees(Double(i) * 30))
                    }

                    // Center cap
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "6A6A5A"),
                                    Color(hex: "4A4A3A")
                                ],
                                center: .init(x: 0.4, y: 0.4),
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 16, height: 16)

                    // Indicator line
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: 8)
                        .offset(y: -10)
                }
            }
            .buttonStyle(.plain)

            // Spacer to align with other controls
            Spacer()
                .frame(height: 10)
        }
    }
}

/// View shown when magnetometer is not available.
private struct SensorUnavailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "C44536"))

            Text("SENSOR OFFLINE")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .tracking(2)
                .foregroundColor(Color(hex: "C0C0B0"))

            Text("Magnetometer not available")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "909080"))
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "3A3A32"))
                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2)
        )
    }
}

/// Safety information and guidelines view
struct SafetyInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // What This App Measures
                    InfoSection(
                        icon: "waveform.path",
                        title: "What This App Measures",
                        content: """
                        This app uses your device's magnetometer to detect magnetic fields (B-field). It measures:

                        • Static magnetic fields (permanent magnets)
                        • Low-frequency AC fields (50/60 Hz from power lines and appliances)
                        • Earth's natural magnetic field (~25-65 µT)

                        The magnetometer is sensitive to fields from DC up to approximately 100 Hz.
                        """
                    )

                    // Safety Guidelines
                    InfoSection(
                        icon: "shield.checkered",
                        title: "Safety Guidelines",
                        content: """
                        International safety limits for magnetic field exposure (ICNIRP):
                        """
                    )

                    // Safety thresholds table
                    VStack(spacing: 0) {
                        SafetyRow(label: "50/60 Hz (power frequency)", value: "200 µT", subvalue: "2,000 mG", isHeader: true)
                        SafetyRow(label: "Static/DC fields", value: "400,000 µT", subvalue: "4,000,000 mG", isHeader: false)
                        SafetyRow(label: "This app's max reading", value: "200 µT", subvalue: "2,000 mG", isHeader: false)
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)

                    // Typical Readings
                    InfoSection(
                        icon: "house",
                        title: "Typical Readings",
                        content: """
                        For context, here are common magnetic field levels:

                        • Earth's field: 25-65 µT (always present)
                        • 1 meter from appliances: 0.01-1 µT
                        • Surface of microwave oven: 5-10 µT
                        • Under power lines: 1-20 µT
                        • Near electric motors: 10-100 µT

                        Most everyday exposures are well below safety guidelines.
                        """
                    )

                    // Limitations
                    InfoSection(
                        icon: "exclamationmark.triangle",
                        title: "Limitations",
                        content: """
                        This app cannot detect:

                        • Radio frequency (RF) fields from WiFi, cellular, etc.
                        • Electric fields (E-field)
                        • Ionizing radiation (X-rays, gamma rays)
                        • High-frequency EMF (above ~100 Hz)

                        Phone magnetometers are not calibrated scientific instruments. Use this app for exploration and education, not for safety compliance testing.
                        """
                    )

                    // Scientific Consensus
                    InfoSection(
                        icon: "checkmark.seal",
                        title: "Scientific Consensus",
                        content: """
                        Major health organizations (WHO, IEEE, ICNIRP) agree that non-ionizing EMF at typical environmental levels has not been shown to cause adverse health effects.

                        Safety guidelines include substantial safety margins and are designed to protect against all established health effects.
                        """
                    )

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("About EMF Safety")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Section header with icon and content
private struct InfoSection: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }

            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Row for safety threshold table
private struct SafetyRow: View {
    let label: String
    let value: String
    let subvalue: String
    let isHeader: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(isHeader ? .primary : .secondary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(isHeader ? .semibold : .regular)
                    .foregroundColor(isHeader ? .accentColor : .primary)
                Text(subvalue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isHeader ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

#Preview {
    MainView()
}

#Preview("Safety Info") {
    SafetyInfoView()
}
