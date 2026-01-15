import SwiftUI

/// Static launch screen view that mirrors the app UI with needle at 0.
/// Used to export a snapshot for the launch screen storyboard.
struct LaunchScreenView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Skeuomorphic metallic device background
                LaunchMetallicBackground()

                VStack(spacing: 0) {
                    // Embossed title plate with info button
                    HStack(spacing: 12) {
                        LaunchTitlePlateView()

                        // Info button (static)
                        ZStack {
                            Circle()
                                .fill(Color(hex: "3A3A32"))
                                .frame(width: 24, height: 24)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)

                            Circle()
                                .stroke(Color(hex: "4A4A42"), lineWidth: 1)
                                .frame(width: 22, height: 22)

                            Text("i")
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .italic()
                                .foregroundColor(Color(hex: "A0A090"))
                        }
                    }
                    .padding(.top, 70)

                    Spacer()

                    // Analog meter display - needle at 0
                    AnalogMeterView(
                        needlePosition: 0,
                        unit: .microTesla,
                        displayValue: 0
                    )

                    Spacer()

                    // Vintage control panel (static)
                    LaunchControlPanelView()
                        .padding(.bottom, 50)
                }

                // Corner rivets
                LaunchRivetsView(size: geometry.size)
            }
        }
        .background(Color(hex: "7A7A70"))
    }
}

// MARK: - Launch Screen Components

private struct LaunchMetallicBackground: View {
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

private struct LaunchTitlePlateView: View {
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
            Text("EMF SCOPE")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .tracking(3)
                .foregroundColor(Color(hex: "C0C0B0"))
                .shadow(color: .black.opacity(0.8), radius: 0, x: 0, y: 1)
        }
    }
}

private struct LaunchControlPanelView: View {
    var body: some View {
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

            // Controls layout (static)
            HStack(alignment: .top, spacing: 30) {
                // Sound toggle (static - ON)
                LaunchToggleView(label: "SOUND", isOn: true)

                // Zero button (static)
                LaunchPushButtonView(label: "ZERO", isSet: false)

                // Settings dial (static)
                LaunchDialView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 320, height: 115)
    }
}

private struct LaunchToggleView: View {
    let label: String
    let isOn: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "2A2A25"))
                    .frame(width: 36, height: 50)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1A1A15"), Color(hex: "252520")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 30, height: 44)

                VStack {
                    Circle()
                        .fill(isOn ? Color(hex: "4CAF50") : Color(hex: "2A2A20"))
                        .frame(width: 6, height: 6)
                        .shadow(color: isOn ? Color(hex: "4CAF50").opacity(0.8) : .clear, radius: 3)
                    Spacer()
                    Circle()
                        .fill(!isOn ? Color(hex: "C44536") : Color(hex: "2A2A20"))
                        .frame(width: 6, height: 6)
                }
                .frame(height: 38)
                .padding(.vertical, 3)

                VStack(spacing: 0) {
                    if !isOn { Spacer() }
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
                    if isOn { Spacer() }
                }
                .frame(width: 30, height: 36)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(isOn ? Color(hex: "4CAF50") : Color(hex: "C44536"))
                    .frame(width: 6, height: 6)
                    .shadow(color: (isOn ? Color(hex: "4CAF50") : Color(hex: "C44536")).opacity(0.6), radius: 3)
                Text(isOn ? "ON" : "OFF")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(isOn ? Color(hex: "4CAF50") : Color(hex: "C44536"))
            }
            .frame(width: 36, height: 10)
        }
    }
}

private struct LaunchPushButtonView: View {
    let label: String
    let isSet: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            ZStack {
                Circle()
                    .fill(Color(hex: "2A2A25"))
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

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
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)

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

            HStack(spacing: 4) {
                Circle()
                    .fill(isSet ? Color(hex: "4CAF50") : Color(hex: "3A3A30"))
                    .frame(width: 6, height: 6)
                    .shadow(color: isSet ? Color(hex: "4CAF50").opacity(0.8) : .clear, radius: 3)
                Text(isSet ? "SET" : "")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(Color(hex: "4CAF50"))
            }
            .frame(width: 36, height: 10)
        }
    }
}

private struct LaunchDialView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("SETTINGS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(hex: "B0B0A0"))

            ZStack {
                Circle()
                    .fill(Color(hex: "2A2A25"))
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 2)

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

                ForEach(0..<12, id: \.self) { i in
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 2, height: 6)
                        .offset(y: -15)
                        .rotationEffect(.degrees(Double(i) * 30))
                }

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

                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 8)
                    .offset(y: -10)
            }

            Spacer()
                .frame(width: 36, height: 10)
        }
    }
}

private struct LaunchRivetsView: View {
    let size: CGSize

    var body: some View {
        let inset: CGFloat = 20
        let rivetSize: CGFloat = 14

        ZStack {
            LaunchRivetView(size: rivetSize)
                .position(x: inset, y: inset + 47)
            LaunchRivetView(size: rivetSize)
                .position(x: size.width - inset, y: inset + 47)
            LaunchRivetView(size: rivetSize)
                .position(x: inset, y: size.height - inset)
            LaunchRivetView(size: rivetSize)
                .position(x: size.width - inset, y: size.height - inset)
            LaunchRivetView(size: rivetSize * 0.8)
                .position(x: size.width / 2, y: inset + 47)
            LaunchRivetView(size: rivetSize * 0.8)
                .position(x: size.width / 2, y: size.height - inset)
        }
    }
}

private struct LaunchRivetView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: size, height: size)
                .offset(x: 1, y: 1)

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

#Preview {
    LaunchScreenView()
}
