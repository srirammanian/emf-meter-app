import SwiftUI

/// App icon view inspired by the vintage analog meter design.
/// This renders the icon programmatically - export at 1024x1024 for the App Store.
struct AppIconView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Background - metallic gray
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "6A6A60"),
                                Color(hex: "7A7A70"),
                                Color(hex: "5A5A50")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subtle texture overlay
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ],
                            center: .init(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: size * 0.7
                        )
                    )

                // Main circular meter
                MeterIconView(size: size * 0.85)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// The circular meter portion of the icon
private struct MeterIconView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Outer black bezel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "3A3A35"),
                            Color(hex: "1A1A18"),
                            Color(hex: "0A0A08")
                        ],
                        center: .init(x: 0.4, y: 0.35),
                        startRadius: size * 0.1,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.5), radius: size * 0.03, x: size * 0.01, y: size * 0.02)

            // Bezel highlight ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.015
                )
                .frame(width: size * 0.95, height: size * 0.95)

            // Inner bezel edge
            Circle()
                .stroke(Color(hex: "2A2A25"), lineWidth: size * 0.02)
                .frame(width: size * 0.82, height: size * 0.82)

            // Aged ivory face
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "F8F3E6"),
                            Color(hex: "F0EBD8"),
                            Color(hex: "E5DCC5")
                        ],
                        center: .init(x: 0.45, y: 0.4),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.78, height: size * 0.78)

            // Blue arc scale
            BlueArcView(size: size)

            // Scale tick marks
            TickMarksView(size: size)

            // EMF text
            Text("EMF")
                .font(.system(size: size * 0.09, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "333333"))
                .offset(y: -size * 0.18)

            // Needle
            NeedleView(size: size, position: 0.65)

            // Center pivot
            PivotView(size: size)
        }
    }
}

/// Blue arc scale band
private struct BlueArcView: View {
    let size: CGFloat

    var body: some View {
        // Main blue arc
        Circle()
            .trim(from: 0.25, to: 0.75)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(hex: "4A7A95"),
                        Color(hex: "5B8FA8"),
                        Color(hex: "4A7A95")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: size * 0.06, lineCap: .butt)
            )
            .frame(width: size * 0.58, height: size * 0.58)
            .rotationEffect(.degrees(180))

        // Danger zone (red portion)
        Circle()
            .trim(from: 0.65, to: 0.75)
            .stroke(
                Color(hex: "C44536"),
                style: StrokeStyle(lineWidth: size * 0.06, lineCap: .butt)
            )
            .frame(width: size * 0.58, height: size * 0.58)
            .rotationEffect(.degrees(180))
    }
}

/// Tick marks on the scale
private struct TickMarksView: View {
    let size: CGFloat

    var body: some View {
        ForEach(0..<11, id: \.self) { i in
            let angle = -90.0 + (Double(i) * 18.0) // 180° sweep, 11 marks
            let isMajor = i % 2 == 0

            Rectangle()
                .fill(Color(hex: "333333"))
                .frame(
                    width: isMajor ? size * 0.015 : size * 0.008,
                    height: isMajor ? size * 0.05 : size * 0.03
                )
                .offset(y: -size * 0.32)
                .rotationEffect(.degrees(angle))
        }
    }
}

/// Needle pointing to a value
private struct NeedleView: View {
    let size: CGFloat
    let position: CGFloat // 0 to 1

    var body: some View {
        let angle = -90.0 + (Double(position) * 180.0)
        let needleLength = size * 0.25
        let needleWidth = size * 0.018

        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            // Apply rotation around center
            var transform = CGAffineTransform.identity
            transform = transform.translatedBy(x: center.x, y: center.y)
            transform = transform.rotated(by: angle * .pi / 180)
            transform = transform.translatedBy(x: -center.x, y: -center.y)

            context.transform = transform

            // Draw needle shadow
            var shadowPath = Path()
            shadowPath.move(to: CGPoint(x: center.x, y: center.y - needleWidth))
            shadowPath.addLine(to: CGPoint(x: center.x - needleLength, y: center.y))
            shadowPath.addLine(to: CGPoint(x: center.x, y: center.y + needleWidth))
            shadowPath.closeSubpath()

            context.fill(
                shadowPath.offsetBy(dx: size * 0.008, dy: size * 0.008),
                with: .color(.black.opacity(0.3))
            )

            // Draw needle body
            var needlePath = Path()
            needlePath.move(to: CGPoint(x: center.x, y: center.y - needleWidth))
            needlePath.addLine(to: CGPoint(x: center.x - needleLength, y: center.y))
            needlePath.addLine(to: CGPoint(x: center.x, y: center.y + needleWidth))
            needlePath.closeSubpath()

            context.fill(needlePath, with: .color(Color(hex: "1A1A18")))
        }
        .frame(width: size * 0.6, height: size * 0.6)
    }
}

/// Center pivot dome
private struct PivotView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Pivot base
            Circle()
                .fill(Color(hex: "1A1A18"))
                .frame(width: size * 0.12, height: size * 0.12)

            // Pivot dome
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "4A4A45"),
                            Color(hex: "2A2A28"),
                            Color(hex: "1A1A18")
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.05
                    )
                )
                .frame(width: size * 0.09, height: size * 0.09)

            // Highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.clear
                        ],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.03
                    )
                )
                .frame(width: size * 0.06, height: size * 0.06)
                .offset(x: -size * 0.01, y: -size * 0.01)
        }
    }
}

// MARK: - Icon Export Helper

/// A view that renders the icon at export size (1024x1024)
struct AppIconExportView: View {
    var body: some View {
        AppIconView()
            .frame(width: 1024, height: 1024)
    }
}

#Preview("App Icon") {
    AppIconView()
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.gray.opacity(0.3))
}

#Preview("App Icon - Export Size") {
    ScrollView([.horizontal, .vertical]) {
        AppIconExportView()
    }
}

#Preview("App Icon - Various Sizes") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            AppIconView()
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 40))

            AppIconView()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 27))

            AppIconView()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }

        HStack(spacing: 20) {
            AppIconView()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 13))

            AppIconView()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 9))

            AppIconView()
                .frame(width: 29, height: 29)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    .padding()
    .background(Color.black)
}
