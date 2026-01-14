import SwiftUI

/// Vintage-style analog meter component inspired by 1950s Geiger counters.
/// Features a circular gauge with black bezel, aged ivory face, and blue arc scale.
struct AnalogMeterView: View {
    let needlePosition: Float
    let unit: EMFUnit
    let displayValue: Float
    @Environment(\.colorScheme) private var colorScheme

    private var colors: MeterColors {
        MeterColors.colors(for: colorScheme)
    }

    private var formattedValue: String {
        UnitConverter.formatValue(displayValue, unit: unit)
    }

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            ZStack {
                // Outer metallic casing
                VintageCasingView(size: size, colors: colors)

                // Brass corner screws
                BrassScrewsView(size: size, colors: colors)

                // Main gauge canvas
                Canvas { context, canvasSize in
                    let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                    let gaugeRadius = size * 0.38

                    // Draw circular black bezel
                    drawBezel(context: context, center: center, radius: gaugeRadius, size: size)

                    // Draw aged ivory face
                    drawFace(context: context, center: center, radius: gaugeRadius * 0.85)

                    // Draw header text "EMF FIELD INTENSITY"
                    drawHeaderText(context: context, center: center, radius: gaugeRadius * 0.72)

                    // Draw blue arc scale
                    drawBlueArc(context: context, center: center, radius: gaugeRadius * 0.62)

                    // Draw scale ticks
                    drawScaleTicks(context: context, center: center, radius: gaugeRadius * 0.62)

                    // Draw scale numbers
                    drawScaleNumbers(context: context, center: center, radius: gaugeRadius * 0.45, unit: unit)

                    // Draw center badge
                    drawCenterBadge(context: context, center: center, radius: gaugeRadius * 0.15)

                    // Draw needle
                    drawNeedle(
                        context: context,
                        center: center,
                        radius: gaugeRadius * 0.55,
                        position: CGFloat(needlePosition)
                    )

                    // Draw needle pivot
                    drawPivot(context: context, center: center, radius: gaugeRadius * 0.08)
                }

                // Company text above gauge
                VStack {
                    Text("PRECISION EMF SCOPE")
                        .font(.system(size: size * 0.028, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(colors.vintageScale.opacity(0.8))

                    Text("SAN FRANCISCO, CA")
                        .font(.system(size: size * 0.022, weight: .regular))
                        .tracking(1)
                        .foregroundColor(colors.vintageScale.opacity(0.6))

                    Spacer()
                }
                .padding(.top, size * 0.04)

                // Digital LCD display and unit label below needle
                VStack(spacing: size * 0.01) {
                    // Unit label
                    Text(unit.symbol)
                        .font(.system(size: size * 0.035, weight: .medium))
                        .foregroundColor(colors.vintageScale)

                    // LCD-style digital value display
                    LCDDisplayView(value: formattedValue, size: size)
                }
                .offset(y: size * 0.22)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    // MARK: - Drawing Functions

    private func drawBezel(context: GraphicsContext, center: CGPoint, radius: CGFloat, size: CGFloat) {
        let bezelWidth = radius * 0.18

        // Outer bezel ring - dark with 3D effect
        let outerBezelPath = Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        // Shadow for depth
        var shadowContext = context
        shadowContext.addFilter(.shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2))
        shadowContext.fill(outerBezelPath, with: .color(colors.vintageBezel))

        // Main bezel with gradient for 3D rim effect
        let bezelGradient = Gradient(colors: [
            colors.vintageBezelHighlight,
            colors.vintageBezel,
            colors.vintageBezel,
            Color.black.opacity(0.8)
        ])
        context.fill(
            outerBezelPath,
            with: .radialGradient(
                bezelGradient,
                center: CGPoint(x: center.x - radius * 0.2, y: center.y - radius * 0.2),
                startRadius: 0,
                endRadius: radius * 1.2
            )
        )

        // Inner bezel edge highlight
        var innerEdgePath = Path()
        innerEdgePath.addArc(
            center: center,
            radius: radius - bezelWidth * 0.3,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        context.stroke(innerEdgePath, with: .color(colors.vintageBezelHighlight.opacity(0.3)), lineWidth: 1)
    }

    private func drawFace(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Aged ivory face with radial gradient
        let facePath = Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        let faceGradient = Gradient(colors: [
            colors.vintageFace,
            colors.vintageFace,
            colors.vintageFaceEdge
        ])

        context.fill(
            facePath,
            with: .radialGradient(
                faceGradient,
                center: CGPoint(x: center.x, y: center.y - radius * 0.2),
                startRadius: 0,
                endRadius: radius * 1.1
            )
        )

        // Subtle aged texture effect - slight darkening at edges
        let edgeShadow = Gradient(colors: [
            .clear,
            .clear,
            colors.vintageFaceEdge.opacity(0.3)
        ])
        context.fill(
            facePath,
            with: .radialGradient(
                edgeShadow,
                center: center,
                startRadius: radius * 0.5,
                endRadius: radius
            )
        )
    }

    private func drawHeaderText(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Draw "EMF FIELD INTENSITY" curved along the top
        let text = "EMF FIELD INTENSITY"
        let fontSize = radius * 0.14

        // Position text along an arc at the top
        let arcRadius = radius * 0.85
        let startAngle: CGFloat = 150 // degrees
        let endAngle: CGFloat = 30 // degrees
        let totalAngle = startAngle - endAngle
        let anglePerChar = totalAngle / CGFloat(text.count - 1)

        for (index, char) in text.enumerated() {
            let charAngle = (startAngle - CGFloat(index) * anglePerChar) * .pi / 180
            let x = center.x + arcRadius * cos(charAngle)
            let y = center.y - arcRadius * sin(charAngle)

            let charText = Text(String(char))
                .font(.system(size: fontSize, weight: .semibold, design: .serif))
                .foregroundColor(colors.vintageScale)

            // Rotate each character to follow the arc
            let rotation = Angle(radians: Double(.pi / 2 - charAngle))
            let resolved = context.resolve(charText)
            context.drawLayer { layerContext in
                layerContext.translateBy(x: x, y: y)
                layerContext.rotate(by: rotation)
                layerContext.draw(resolved, at: .zero, anchor: .center)
            }
        }
    }

    private func drawBlueArc(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let arcWidth: CGFloat = radius * 0.12

        // Main blue arc - full 180 degrees
        var bluePath = Path()
        bluePath.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )

        context.stroke(
            bluePath,
            with: .color(colors.vintageArc),
            style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
        )

        // Danger zone - last 20% in red
        var dangerPath = Path()
        dangerPath.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(36),
            endAngle: .degrees(0),
            clockwise: true
        )

        context.stroke(
            dangerPath,
            with: .color(Color(hex: "C44536").opacity(0.8)),
            style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
        )

        // Inner arc edge line
        var innerEdge = Path()
        innerEdge.addArc(
            center: center,
            radius: radius - arcWidth / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        context.stroke(innerEdge, with: .color(colors.vintageScale.opacity(0.3)), lineWidth: 0.5)

        // Outer arc edge line
        var outerEdge = Path()
        outerEdge.addArc(
            center: center,
            radius: radius + arcWidth / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        context.stroke(outerEdge, with: .color(colors.vintageScale.opacity(0.3)), lineWidth: 0.5)
    }

    private func drawScaleTicks(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        let majorDivisions = 10
        let minorPerMajor = 5
        let totalTicks = majorDivisions * minorPerMajor
        let arcWidth: CGFloat = radius * 0.12

        for i in 0...totalTicks {
            let isMajor = i % minorPerMajor == 0
            let angle = CGFloat((180.0 - Double(i) * (180.0 / Double(totalTicks))) * .pi / 180)

            let innerRadius = radius + arcWidth / 2
            let outerRadius = innerRadius + (isMajor ? radius * 0.12 : radius * 0.06)

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
                with: .color(colors.vintageScale),
                lineWidth: isMajor ? 2.0 : 1.0
            )
        }
    }

    private func drawScaleNumbers(context: GraphicsContext, center: CGPoint, radius: CGFloat, unit: EMFUnit) {
        let labels = UnitConverter.getScaleLabels(for: unit, divisions: MeterConfig.majorDivisions)
        let fontSize = radius * 0.22

        // Show every other label (0, 2, 4, 6, 8, 10)
        for i in stride(from: 0, through: MeterConfig.majorDivisions, by: 2) {
            let angle = CGFloat((180.0 - Double(i) * 18.0) * .pi / 180)
            let x = center.x + radius * cos(angle)
            let y = center.y - radius * sin(angle)

            if let labelText = labels[safe: i] {
                let text = Text(labelText)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundColor(colors.vintageScale)

                let resolved = context.resolve(text)
                context.draw(resolved, at: CGPoint(x: x, y: y), anchor: .center)
            }
        }
    }

    private func drawCenterBadge(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Blue circular badge
        let badgePath = Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        // Badge background
        context.fill(badgePath, with: .color(colors.vintageArc))

        // Badge border
        context.stroke(badgePath, with: .color(colors.vintageScale.opacity(0.5)), lineWidth: 1)

        // Badge text
        let text = Text("EMF")
            .font(.system(size: radius * 0.6, weight: .bold, design: .serif))
            .foregroundColor(.white)

        let resolved = context.resolve(text)
        context.draw(resolved, at: center, anchor: .center)
    }

    private func drawNeedle(context: GraphicsContext, center: CGPoint, radius: CGFloat, position: CGFloat) {
        let clampedPosition = min(max(position, 0), 1)
        let needleAngle = CGFloat((180.0 - Double(clampedPosition) * 180.0) * .pi / 180)

        // Needle dimensions
        let needleLength = radius
        let baseWidth: CGFloat = 4

        // Calculate needle points
        let tipX = center.x + needleLength * cos(needleAngle)
        let tipY = center.y - needleLength * sin(needleAngle)

        let perpAngle = needleAngle + .pi / 2
        let baseOffsetX = baseWidth * cos(perpAngle)
        let baseOffsetY = baseWidth * sin(perpAngle)

        // Tail extension behind pivot
        let tailLength = radius * 0.15
        let tailX = center.x - tailLength * cos(needleAngle)
        let tailY = center.y + tailLength * sin(needleAngle)
        let tailOffsetX = (baseWidth * 0.8) * cos(perpAngle)
        let tailOffsetY = (baseWidth * 0.8) * sin(perpAngle)

        // Shadow
        var shadowPath = Path()
        shadowPath.move(to: CGPoint(x: tailX + 2, y: tailY + 2))
        shadowPath.addLine(to: CGPoint(x: tipX + 2, y: tipY + 2))
        context.stroke(shadowPath, with: .color(.black.opacity(0.3)), lineWidth: 4)

        // Needle body - tapered shape with tail
        var needlePath = Path()
        // Start at tail
        needlePath.move(to: CGPoint(x: tailX + tailOffsetX, y: tailY - tailOffsetY))
        needlePath.addLine(to: CGPoint(x: tailX - tailOffsetX, y: tailY + tailOffsetY))
        // To base
        needlePath.addLine(to: CGPoint(x: center.x - baseOffsetX, y: center.y + baseOffsetY))
        // To tip
        needlePath.addLine(to: CGPoint(x: tipX, y: tipY))
        // Back to base other side
        needlePath.addLine(to: CGPoint(x: center.x + baseOffsetX, y: center.y - baseOffsetY))
        needlePath.closeSubpath()

        context.fill(needlePath, with: .color(colors.vintageNeedle))

        // Needle highlight line
        var highlightPath = Path()
        highlightPath.move(to: CGPoint(x: center.x, y: center.y))
        highlightPath.addLine(to: CGPoint(x: tipX, y: tipY))
        context.stroke(highlightPath, with: .color(colors.vintageNeedle.opacity(0.5)), lineWidth: 1)
    }

    private func drawPivot(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // Shadow
        let shadowPath = Path(ellipseIn: CGRect(
            x: center.x - radius + 2,
            y: center.y - radius + 2,
            width: radius * 2,
            height: radius * 2
        ))
        context.fill(shadowPath, with: .color(.black.opacity(0.4)))

        // Main pivot dome
        let pivotPath = Path(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))

        let pivotGradient = Gradient(colors: [
            Color(hex: "5A5A5A"),
            colors.vintagePivot,
            Color.black
        ])

        context.fill(
            pivotPath,
            with: .radialGradient(
                pivotGradient,
                center: CGPoint(x: center.x - radius * 0.3, y: center.y - radius * 0.3),
                startRadius: 0,
                endRadius: radius * 1.2
            )
        )

        // Highlight
        let highlightPath = Path(ellipseIn: CGRect(
            x: center.x - radius * 0.5,
            y: center.y - radius * 0.6,
            width: radius * 0.6,
            height: radius * 0.4
        ))
        context.fill(highlightPath, with: .color(.white.opacity(0.25)))
    }
}

// MARK: - Supporting Views

/// Outer metallic casing for the vintage meter
private struct VintageCasingView: View {
    let size: CGFloat
    let colors: MeterColors

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.06)
            .fill(
                LinearGradient(
                    colors: [
                        colors.vintageCasing,
                        colors.vintageCasingDark,
                        colors.vintageCasing.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.06)
                    .stroke(
                        LinearGradient(
                            colors: [
                                colors.vintageCasing.opacity(0.8),
                                colors.vintageCasingDark
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
    }
}

/// Decorative brass screws at corners
private struct BrassScrewsView: View {
    let size: CGFloat
    let colors: MeterColors

    var body: some View {
        let screwSize = size * 0.055
        let inset = size * 0.06

        ZStack {
            // Top left
            BrassScrewView(size: screwSize, colors: colors)
                .position(x: inset, y: inset)

            // Top right
            BrassScrewView(size: screwSize, colors: colors)
                .position(x: size - inset, y: inset)

            // Bottom left
            BrassScrewView(size: screwSize, colors: colors)
                .position(x: inset, y: size - inset)

            // Bottom right
            BrassScrewView(size: screwSize, colors: colors)
                .position(x: size - inset, y: size - inset)
        }
        .frame(width: size, height: size)
    }
}

/// Single brass screw decoration
private struct BrassScrewView: View {
    let size: CGFloat
    let colors: MeterColors

    var body: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: size, height: size)
                .offset(x: 1, y: 1)

            // Main screw body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            colors.vintageBrassHighlight,
                            colors.vintageBrass,
                            colors.vintageBrassShadow
                        ],
                        center: .init(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Slot
            Rectangle()
                .fill(colors.vintageBrassShadow)
                .frame(width: size * 0.6, height: size * 0.15)
                .rotationEffect(.degrees(-30))
        }
    }
}

/// 80s-style LCD calculator display
private struct LCDDisplayView: View {
    let value: String
    let size: CGFloat

    // LCD green-black color scheme
    private let lcdBackground = Color(hex: "1A2E1A")
    private let lcdText = Color(hex: "39FF14")
    private let lcdShadow = Color(hex: "0D170D")
    private let lcdBezel = Color(hex: "2A2A2A")

    var body: some View {
        let displayWidth = size * 0.28
        let displayHeight = size * 0.08

        ZStack {
            // Outer bezel
            RoundedRectangle(cornerRadius: 4)
                .fill(lcdBezel)
                .frame(width: displayWidth + 6, height: displayHeight + 6)

            // LCD screen background with inset effect
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [lcdShadow, lcdBackground, lcdBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: displayWidth, height: displayHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                )

            // Ghost segments (dimmed background)
            Text("8888.8")
                .font(.custom("Menlo", size: size * 0.045))
                .fontWeight(.bold)
                .foregroundColor(lcdText.opacity(0.1))
                .frame(width: displayWidth, height: displayHeight)

            // Active LCD digits
            Text(value)
                .font(.custom("Menlo", size: size * 0.045))
                .fontWeight(.bold)
                .foregroundColor(lcdText)
                .shadow(color: lcdText.opacity(0.5), radius: 2, x: 0, y: 0)
                .frame(width: displayWidth, height: displayHeight)
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
    VStack(spacing: 20) {
        AnalogMeterView(needlePosition: 0.3, unit: .microTesla, displayValue: 60.0)
            .frame(height: 350)

        AnalogMeterView(needlePosition: 0.7, unit: .milliGauss, displayValue: 1400.0)
            .frame(height: 350)
    }
    .background(Color.backgroundLight)
}
