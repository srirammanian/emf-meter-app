import SwiftUI

/// Vintage CRT-style oscilloscope view displaying EMF readings over time.
struct OscilloscopeView: View {
    let readings: [TimestampedReading]
    let maxValue: Float
    let isProUser: Bool
    let onUpgradeNeeded: () -> Void

    private let visibleDuration: TimeInterval = 30  // 30 seconds visible

    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isProUser {
                    // Full oscilloscope for Pro users
                    oscilloscopeContent(in: geometry.size)
                    // Axis labels overlay
                    axisLabels(in: geometry.size)
                } else {
                    // Locked view for free users
                    lockedView(in: geometry.size)
                }
            }
        }
        .aspectRatio(3.0, contentMode: .fit)
    }

    // MARK: - Axis Labels

    @ViewBuilder
    private func axisLabels(in size: CGSize) -> some View {
        let padding: CGFloat = 12

        ZStack {
            // Y-axis labels (magnitude)
            VStack {
                Text("\(Int(maxValue))")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
                Spacer()
                Text("\(Int(maxValue / 2))")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
                Spacer()
                Text("0")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
            }
            .padding(.vertical, padding + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, padding + 2)

            // X-axis labels (time)
            HStack {
                Text("-30s")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
                Spacer()
                Text("-15s")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
                Spacer()
                Text("0s")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.7))
            }
            .padding(.horizontal, padding + 12)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, padding - 2)
        }
    }

    // MARK: - Oscilloscope Content

    @ViewBuilder
    private func oscilloscopeContent(in size: CGSize) -> some View {
        ZStack {
            // CRT Background
            crtBackground

            // Grid lines (graticule)
            graticule(in: size)

            // Waveform trace
            waveform(in: size)

            // Phosphor glow overlay
            phosphorGlow

            // Scan lines effect
            scanLines(in: size)

            // Glass reflection
            glassReflection

            // Bezel frame
            bezelFrame
        }
        .gesture(dragGesture)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Locked View

    @ViewBuilder
    private func lockedView(in size: CGSize) -> some View {
        ZStack {
            // Dimmed CRT background
            crtBackground
                .opacity(0.5)

            // Grid (faded)
            graticule(in: size)
                .opacity(0.3)

            // Lock overlay
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.6))

                Text("Pro Feature")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.oscilloscopeTrace.opacity(0.6))
            }

            // Bezel frame
            bezelFrame
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            onUpgradeNeeded()
        }
    }

    // MARK: - CRT Effects

    private var crtBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                RadialGradient(
                    colors: [.oscilloscopeBackground, .oscilloscopeBackgroundEdge],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            )
    }

    private func graticule(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let gridColor = Color.oscilloscopeGrid.opacity(0.6)
            let padding: CGFloat = 12

            let drawWidth = canvasSize.width - padding * 2
            let drawHeight = canvasSize.height - padding * 2

            // Vertical lines (time divisions) - 10 divisions
            for i in 0...10 {
                let x = padding + drawWidth * CGFloat(i) / 10
                var path = Path()
                path.move(to: CGPoint(x: x, y: padding))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height - padding))

                // Center line is brighter
                let lineWidth: CGFloat = (i == 5) ? 1.0 : 0.5
                context.stroke(path, with: .color(gridColor), lineWidth: lineWidth)
            }

            // Horizontal lines (magnitude divisions) - 4 divisions
            for i in 0...4 {
                let y = padding + drawHeight * CGFloat(i) / 4
                var path = Path()
                path.move(to: CGPoint(x: padding, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width - padding, y: y))

                // Center line is brighter
                let lineWidth: CGFloat = (i == 2) ? 1.0 : 0.5
                context.stroke(path, with: .color(gridColor), lineWidth: lineWidth)
            }

            // Small tick marks on center lines
            let tickSize: CGFloat = 4
            let tickSpacing: CGFloat = drawWidth / 50

            // Vertical ticks on horizontal center line
            let centerY = padding + drawHeight / 2
            for x in stride(from: padding, through: canvasSize.width - padding, by: tickSpacing) {
                var tick = Path()
                tick.move(to: CGPoint(x: x, y: centerY - tickSize / 2))
                tick.addLine(to: CGPoint(x: x, y: centerY + tickSize / 2))
                context.stroke(tick, with: .color(gridColor), lineWidth: 0.5)
            }

            // Horizontal ticks on vertical center line
            let centerX = padding + drawWidth / 2
            let tickSpacingV = drawHeight / 20
            for y in stride(from: padding, through: canvasSize.height - padding, by: tickSpacingV) {
                var tick = Path()
                tick.move(to: CGPoint(x: centerX - tickSize / 2, y: y))
                tick.addLine(to: CGPoint(x: centerX + tickSize / 2, y: y))
                context.stroke(tick, with: .color(gridColor), lineWidth: 0.5)
            }
        }
    }

    private func waveform(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            guard readings.count > 1 else { return }

            let padding: CGFloat = 12
            let drawWidth = canvasSize.width - padding * 2
            let drawHeight = canvasSize.height - padding * 2

            let totalOffset = scrollOffset + dragOffset
            let pixelsPerSecond = drawWidth / visibleDuration

            // Get the latest timestamp
            let latestTimestamp = readings.last?.timestamp ?? 0

            var path = Path()
            var firstPoint = true

            for reading in readings {
                // Calculate x position relative to the right edge (most recent)
                let timeSinceLatest = latestTimestamp - reading.timestamp
                let x = padding + drawWidth - (timeSinceLatest * pixelsPerSecond) + totalOffset

                // Skip points outside visible area
                guard x >= padding - 10 && x <= canvasSize.width - padding + 10 else { continue }

                let normalizedY = CGFloat(min(reading.magnitude / maxValue, 1.0))
                let y = padding + drawHeight * (1 - normalizedY)

                if firstPoint {
                    path.move(to: CGPoint(x: x, y: y))
                    firstPoint = false
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            // Draw glow layer first
            context.stroke(path, with: .color(.oscilloscopeTrace.opacity(0.3)), lineWidth: 6)

            // Draw main trace
            context.stroke(path, with: .color(.oscilloscopeTrace), lineWidth: 2)

            // Draw bright center line
            context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
        }
        .blur(radius: 0.3)  // Subtle phosphor blur
    }

    private var phosphorGlow: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.oscilloscopeTrace.opacity(0.02))
            .blur(radius: 30)
    }

    private func scanLines(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for y in stride(from: 0, to: canvasSize.height, by: 2) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(path, with: .color(.black.opacity(0.08)), lineWidth: 1)
            }
        }
    }

    private var glassReflection: some View {
        LinearGradient(
            colors: [
                .white.opacity(0.05),
                .clear,
                .clear,
                .white.opacity(0.02)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var bezelFrame: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    colors: [.oscilloscopeBezel, .oscilloscopeBezelDark],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 6
            )
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                // Only allow scrolling back in time (positive offset)
                let newOffset = value.translation.width
                state = newOffset
            }
            .onEnded { value in
                scrollOffset += value.translation.width
                // Can't scroll past present (positive offset = scrolling back in time)
                // Limit how far back we can scroll based on data
                let maxScroll = max(0, CGFloat((readings.last?.timestamp ?? 0) - visibleDuration) * 10)
                scrollOffset = min(max(0, scrollOffset), maxScroll)
            }
    }
}

// MARK: - Preview

#Preview("Oscilloscope - Pro") {
    let readings = (0..<300).map { i in
        TimestampedReading(
            timestamp: Double(i) * 0.1,
            x: Float.random(in: 20...80),
            y: Float.random(in: 20...80),
            z: Float.random(in: 20...80),
            magnitude: Float.random(in: 30...120)
        )
    }

    return VStack {
        OscilloscopeView(
            readings: readings,
            maxValue: 200,
            isProUser: true,
            onUpgradeNeeded: {}
        )
        .frame(height: 120)
        .padding()
    }
    .background(Color.black)
}

#Preview("Oscilloscope - Locked") {
    VStack {
        OscilloscopeView(
            readings: [],
            maxValue: 200,
            isProUser: false,
            onUpgradeNeeded: {}
        )
        .frame(height: 120)
        .padding()
    }
    .background(Color.black)
}
