import SwiftUI

/// Digital display component showing EMF readings in LCD calculator style.
struct DigitalDisplayView: View {
    let value: Float
    let unit: EMFUnit
    @Environment(\.colorScheme) private var colorScheme

    private var colors: MeterColors {
        MeterColors.colors(for: colorScheme)
    }

    private var formattedValue: String {
        UnitConverter.formatValue(value, unit: unit)
    }

    var body: some View {
        VStack {
            // Outer frame (device housing)
            ZStack {
                // Housing background
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4A4A4A"),
                                Color(hex: "3A3A3A"),
                                Color(hex: "2A2A2A")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "1A1A1A"), lineWidth: 2)
                    )

                // LCD screen
                VStack(spacing: 16) {
                    // Main value display
                    Text(formattedValue)
                        .font(.system(size: 72, weight: .bold, design: .monospaced))
                        .tracking(8)
                        .foregroundColor(colors.digitalText)

                    // Unit and indicators
                    HStack(spacing: 16) {
                        Text(unit.symbol)
                            .font(.system(size: 28, weight: .medium, design: .monospaced))
                            .foregroundColor(colors.digitalText.opacity(0.9))

                        // Indicator dots
                        HStack(spacing: 4) {
                            IndicatorDot(active: true, color: colors.digitalText)
                            IndicatorDot(active: value > 0, color: colors.digitalText)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    colors.digitalBackground.opacity(0.95),
                                    colors.digitalBackground,
                                    colors.digitalBackground.opacity(0.9)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "111111"), lineWidth: 3)
                        )
                )
                .padding(16)
            }
        }
        .padding()
    }
}

/// Small indicator dot for the digital display.
private struct IndicatorDot: View {
    let active: Bool
    let color: Color

    var body: some View {
        Circle()
            .fill(active ? color : color.opacity(0.2))
            .frame(width: 8, height: 8)
    }
}

#Preview {
    VStack {
        DigitalDisplayView(value: 123.4, unit: .milliGauss)
    }
    .background(Color.backgroundDark)
}
