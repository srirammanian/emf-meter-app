import SwiftUI

/// Analog meter component with realistic needle physics.
struct AnalogMeterView: View {
    let needlePosition: Float
    let unit: EMFUnit
    @Environment(\.colorScheme) private var colorScheme

    private var colors: MeterColors {
        MeterColors.colors(for: colorScheme)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height * 1.3)

            ZStack {
                // Outer bezel
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                colors.bezel.opacity(0.9),
                                colors.bezel,
                                colors.bezel.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size, height: size * 0.77)

                // Meter face
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.face)
                    .frame(width: size - 24, height: size * 0.77 - 24)

                // Meter canvas
                Canvas { context, canvasSize in
                    let centerX = canvasSize.width / 2
                    let centerY = canvasSize.height * 0.85
                    let radius = canvasSize.width * 0.38

                    // Draw arc background
                    drawArcBackground(
                        context: context,
                        center: CGPoint(x: centerX, y: centerY),
                        radius: radius
                    )

                    // Draw danger zone
                    drawDangerZone(
                        context: context,
                        center: CGPoint(x: centerX, y: centerY),
                        radius: radius
                    )

                    // Draw scale ticks
                    drawScaleTicks(
                        context: context,
                        center: CGPoint(x: centerX, y: centerY),
                        radius: radius
                    )

                    // Draw needle
                    drawNeedle(
                        context: context,
                        center: CGPoint(x: centerX, y: centerY),
                        radius: radius,
                        position: CGFloat(needlePosition)
                    )
                }
                .frame(width: size - 24, height: size * 0.77 - 24)

                // Scale labels
                ScaleLabelsView(
                    unit: unit,
                    size: size
                )

                // Unit label
                Text(unit.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colors.scale)
                    .offset(y: size * 0.15)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1.3, contentMode: .fit)
        .padding()
    }

    private func drawArcBackground(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(225),
            endAngle: .degrees(315),
            clockwise: false
        )

        context.stroke(
            path,
            with: .color(colors.bezel.opacity(0.3)),
            lineWidth: 30
        )
    }

    private func drawDangerZone(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(135),
            endAngle: .degrees(153),
            clockwise: true
        )

        context.stroke(
            path,
            with: .color(.red.opacity(0.2)),
            lineWidth: 25
        )
    }

    private func drawScaleTicks(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let totalTicks = MeterConfig.majorDivisions * MeterConfig.minorDivisions
        let degreesPerTick = 90.0 / Double(totalTicks)

        for i in 0...totalTicks {
            let isMajor = i % MeterConfig.minorDivisions == 0
            let angle = (225.0 - Double(i) * degreesPerTick) * .pi / 180

            let innerRadius = radius * (isMajor ? 0.82 : 0.87)
            let outerRadius = radius * 0.95

            var tickPath = Path()
            tickPath.move(to: CGPoint(
                x: center.x + innerRadius * cos(angle),
                y: center.y - innerRadius * sin(angle)
            ))
            tickPath.addLine(to: CGPoint(
                x: center.x + outerRadius * cos(angle),
                y: center.y - outerRadius * sin(angle)
            ))

            context.stroke(
                tickPath,
                with: .color(colors.scale),
                lineWidth: isMajor ? 3 : 1.5
            )
        }
    }

    private func drawNeedle(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        position: CGFloat
    ) {
        let clampedPosition = min(max(position, 0), 1)
        let needleAngle = (225.0 - Double(clampedPosition) * 90.0) * .pi / 180
        let needleLength = radius * 0.78

        // Shadow
        var shadowPath = Path()
        shadowPath.move(to: CGPoint(x: center.x + 2, y: center.y + 2))
        shadowPath.addLine(to: CGPoint(
            x: center.x + needleLength * cos(needleAngle) + 2,
            y: center.y - needleLength * sin(needleAngle) + 2
        ))
        context.stroke(shadowPath, with: .color(.black.opacity(0.3)), lineWidth: 5)

        // Needle body
        var needlePath = Path()
        needlePath.move(to: CGPoint(x: center.x - 4, y: center.y))
        needlePath.addLine(to: CGPoint(
            x: center.x + needleLength * cos(needleAngle),
            y: center.y - needleLength * sin(needleAngle)
        ))
        needlePath.addLine(to: CGPoint(x: center.x + 4, y: center.y))
        needlePath.closeSubpath()

        context.fill(needlePath, with: .color(colors.needle))

        // Pivot shadow
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - 12 + 2,
                y: center.y - 12 + 2,
                width: 24,
                height: 24
            )),
            with: .color(.black.opacity(0.3))
        )

        // Pivot
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - 12,
                y: center.y - 12,
                width: 24,
                height: 24
            )),
            with: .color(colors.pivot)
        )

        // Pivot highlight
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x - 9,
                y: center.y - 9,
                width: 12,
                height: 12
            )),
            with: .color(.white.opacity(0.3))
        )
    }
}

/// Scale labels around the meter arc.
private struct ScaleLabelsView: View {
    let unit: EMFUnit
    let size: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    private var colors: MeterColors {
        MeterColors.colors(for: colorScheme)
    }

    var body: some View {
        let labels = UnitConverter.getScaleLabels(for: unit, divisions: MeterConfig.majorDivisions)
        let centerY = size * 0.77 * 0.85
        let radius = size * 0.38 * 0.65

        ZStack {
            ForEach(Array(stride(from: 0, through: MeterConfig.majorDivisions, by: 2)), id: \.self) { i in
                let angle = (225.0 - Double(i) * 9.0) * .pi / 180
                let x = radius * cos(angle)
                let y = -radius * sin(angle)

                if let label = labels[safe: i] {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.scale)
                        .offset(x: x, y: y + (centerY - size * 0.77 / 2))
                }
            }
        }
    }
}

// Safe array access
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    VStack {
        AnalogMeterView(needlePosition: 0.5, unit: .milliGauss)
            .frame(height: 300)
    }
    .background(Color.backgroundLight)
}
