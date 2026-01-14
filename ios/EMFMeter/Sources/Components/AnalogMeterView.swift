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
            let width = geometry.size.width
            let height = geometry.size.height

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

                // Meter face
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.face)
                    .padding(12)

                // Meter canvas
                Canvas { context, canvasSize in
                    let centerX = canvasSize.width / 2
                    let centerY = canvasSize.height * 0.85
                    let radius = min(canvasSize.width * 0.45, canvasSize.height * 0.75)

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
                .padding(12)

                // Scale labels
                ScaleLabelsView(
                    unit: unit,
                    width: width,
                    height: height
                )

                // Unit label
                Text(unit.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colors.scale)
                    .offset(y: height * 0.15)
            }
        }
        .aspectRatio(16.0/9.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    private func drawArcBackground(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        var path = Path()
        // Full 180° semicircle from left (180°) to right (0°)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )

        context.stroke(
            path,
            with: .color(colors.bezel.opacity(0.3)),
            lineWidth: 20
        )
    }

    private func drawDangerZone(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        var path = Path()
        // Danger zone at the high end (right side, last 20% of arc)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(36),
            endAngle: .degrees(0),
            clockwise: true
        )

        context.stroke(
            path,
            with: .color(.red.opacity(0.3)),
            lineWidth: 18
        )
    }

    private func drawScaleTicks(
        context: GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let totalTicks = MeterConfig.majorDivisions * MeterConfig.minorDivisions
        // 180° sweep from left to right
        let degreesPerTick = 180.0 / Double(totalTicks)

        for i in 0...totalTicks {
            let isMajor = i % MeterConfig.minorDivisions == 0
            // Start at 180° (left) and go to 0° (right)
            let angle = CGFloat((180.0 - Double(i) * degreesPerTick) * .pi / 180)

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
                lineWidth: isMajor ? 2.5 : 1
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
        // Needle sweeps from 180° (left, min) to 0° (right, max)
        let needleAngle = CGFloat((180.0 - Double(clampedPosition) * 180.0) * .pi / 180)
        let needleLength = radius * 0.78
        let baseWidth: CGFloat = 5

        // Calculate perpendicular offset for needle base
        let perpAngle = needleAngle + .pi / 2
        let baseOffsetX = baseWidth * cos(perpAngle)
        let baseOffsetY = baseWidth * sin(perpAngle)

        // Needle tip
        let tipX = center.x + needleLength * cos(needleAngle)
        let tipY = center.y - needleLength * sin(needleAngle)

        // Shadow
        var shadowPath = Path()
        shadowPath.move(to: CGPoint(x: center.x + 2, y: center.y + 2))
        shadowPath.addLine(to: CGPoint(x: tipX + 2, y: tipY + 2))
        context.stroke(shadowPath, with: .color(.black.opacity(0.3)), lineWidth: 5)

        // Needle body - base is perpendicular to needle direction
        var needlePath = Path()
        needlePath.move(to: CGPoint(x: center.x + baseOffsetX, y: center.y - baseOffsetY))
        needlePath.addLine(to: CGPoint(x: tipX, y: tipY))
        needlePath.addLine(to: CGPoint(x: center.x - baseOffsetX, y: center.y + baseOffsetY))
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
    let width: CGFloat
    let height: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    private var colors: MeterColors {
        MeterColors.colors(for: colorScheme)
    }

    var body: some View {
        let labels = UnitConverter.getScaleLabels(for: unit, divisions: MeterConfig.majorDivisions)
        let centerY = height * 0.85
        let radius = min(width * 0.45, height * 0.75) * 0.72
        // 180° sweep, so each major division is 18° apart (180/10)
        let degreesPerDivision = 180.0 / Double(MeterConfig.majorDivisions)

        ZStack {
            // Show every other label to avoid crowding
            ForEach(Array(stride(from: 0, through: MeterConfig.majorDivisions, by: 2)), id: \.self) { i in
                // Start at 180° (left) and go to 0° (right)
                let angle = CGFloat((180.0 - Double(i) * degreesPerDivision) * .pi / 180)
                let x = radius * cos(angle)
                let y = -radius * sin(angle)

                if let label = labels[safe: i] {
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(colors.scale)
                        .offset(x: x, y: y + (centerY - height / 2))
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
