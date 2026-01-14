package com.emfmeter.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emfmeter.domain.EMFUnit
import com.emfmeter.domain.MeterConfig
import com.emfmeter.ui.theme.EMFMeterTheme
import com.emfmeter.util.UnitConverter
import kotlin.math.cos
import kotlin.math.sin

/**
 * Analog meter component with realistic needle physics.
 * Displays EMF readings in a classic Geiger counter style.
 */
@Composable
fun AnalogMeter(
    needlePosition: Float,
    unit: EMFUnit,
    modifier: Modifier = Modifier
) {
    val meterColors = EMFMeterTheme.meterColors
    val textMeasurer = rememberTextMeasurer()
    val scaleLabels = UnitConverter.getScaleLabels(unit, MeterConfig.MAJOR_DIVISIONS)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        // Outer bezel
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1.3f)
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            meterColors.bezel.copy(alpha = 0.9f),
                            meterColors.bezel,
                            meterColors.bezel.copy(alpha = 0.8f)
                        )
                    ),
                    shape = RoundedCornerShape(16.dp)
                )
                .padding(12.dp)
        ) {
            // Meter face
            Canvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1.3f)
                    .background(
                        color = meterColors.face,
                        shape = RoundedCornerShape(8.dp)
                    )
            ) {
                val centerX = size.width / 2
                val centerY = size.height * 0.9f
                val radius = size.width * 0.38f

                // Draw arc background
                drawArc(
                    color = meterColors.bezel.copy(alpha = 0.3f),
                    startAngle = 225f,
                    sweepAngle = -90f,
                    useCenter = false,
                    topLeft = Offset(centerX - radius, centerY - radius),
                    size = Size(radius * 2, radius * 2),
                    style = Stroke(width = 30f)
                )

                // Draw danger zone (last 20%)
                drawArc(
                    color = Color.Red.copy(alpha = 0.2f),
                    startAngle = 153f,
                    sweepAngle = -18f,
                    useCenter = false,
                    topLeft = Offset(centerX - radius, centerY - radius),
                    size = Size(radius * 2, radius * 2),
                    style = Stroke(width = 25f)
                )

                // Draw scale ticks and labels
                drawScaleMarks(
                    centerX = centerX,
                    centerY = centerY,
                    radius = radius,
                    majorDivisions = MeterConfig.MAJOR_DIVISIONS,
                    minorDivisions = MeterConfig.MINOR_DIVISIONS,
                    tickColor = meterColors.scale
                )

                // Draw scale labels
                for (i in 0..MeterConfig.MAJOR_DIVISIONS step 2) {
                    val angle = Math.toRadians((225.0 - i * 9.0))
                    val labelRadius = radius * 0.65f
                    val label = scaleLabels.getOrNull(i) ?: ""

                    val textLayoutResult = textMeasurer.measure(
                        text = label,
                        style = TextStyle(
                            fontSize = 12.sp,
                            color = meterColors.scale
                        )
                    )

                    drawText(
                        textLayoutResult = textLayoutResult,
                        topLeft = Offset(
                            x = centerX + (labelRadius * cos(angle)).toFloat() - textLayoutResult.size.width / 2,
                            y = centerY - (labelRadius * sin(angle)).toFloat() - textLayoutResult.size.height / 2
                        )
                    )
                }

                // Draw unit label
                val unitLabel = textMeasurer.measure(
                    text = unit.symbol,
                    style = TextStyle(
                        fontSize = 16.sp,
                        color = meterColors.scale
                    )
                )
                drawText(
                    textLayoutResult = unitLabel,
                    topLeft = Offset(
                        x = centerX - unitLabel.size.width / 2,
                        y = centerY - radius * 0.35f
                    )
                )

                // Draw needle
                drawNeedle(
                    centerX = centerX,
                    centerY = centerY,
                    radius = radius,
                    position = needlePosition,
                    needleColor = meterColors.needle,
                    pivotColor = meterColors.pivot
                )
            }
        }
    }
}

private fun DrawScope.drawScaleMarks(
    centerX: Float,
    centerY: Float,
    radius: Float,
    majorDivisions: Int,
    minorDivisions: Int,
    tickColor: Color
) {
    val totalTicks = majorDivisions * minorDivisions
    val degreesPerTick = 90f / totalTicks

    for (i in 0..totalTicks) {
        val isMajor = i % minorDivisions == 0
        val angle = Math.toRadians((225.0 - i * degreesPerTick))
        val innerRadius = radius * (if (isMajor) 0.82f else 0.87f)
        val outerRadius = radius * 0.95f

        drawLine(
            color = tickColor,
            start = Offset(
                x = centerX + (innerRadius * cos(angle)).toFloat(),
                y = centerY - (innerRadius * sin(angle)).toFloat()
            ),
            end = Offset(
                x = centerX + (outerRadius * cos(angle)).toFloat(),
                y = centerY - (outerRadius * sin(angle)).toFloat()
            ),
            strokeWidth = if (isMajor) 3f else 1.5f,
            cap = StrokeCap.Round
        )
    }
}

private fun DrawScope.drawNeedle(
    centerX: Float,
    centerY: Float,
    radius: Float,
    position: Float,
    needleColor: Color,
    pivotColor: Color
) {
    // Calculate needle angle (225 degrees = 0, 135 degrees = 1)
    val needleAngle = 225f - (position.coerceIn(0f, 1f) * 90f)
    val needleLength = radius * 0.78f

    rotate(degrees = -needleAngle + 90f, pivot = Offset(centerX, centerY)) {
        // Needle shadow
        drawLine(
            color = Color.Black.copy(alpha = 0.3f),
            start = Offset(centerX + 2f, centerY + 2f),
            end = Offset(centerX + 2f, centerY - needleLength + 2f),
            strokeWidth = 5f,
            cap = StrokeCap.Round
        )

        // Needle body
        val needlePath = Path().apply {
            moveTo(centerX - 4f, centerY)
            lineTo(centerX, centerY - needleLength)
            lineTo(centerX + 4f, centerY)
            close()
        }
        drawPath(
            path = needlePath,
            color = needleColor
        )

        // Needle tip
        drawLine(
            color = needleColor,
            start = Offset(centerX, centerY - needleLength * 0.2f),
            end = Offset(centerX, centerY - needleLength),
            strokeWidth = 3f,
            cap = StrokeCap.Round
        )
    }

    // Center pivot - shadow
    drawCircle(
        color = Color.Black.copy(alpha = 0.3f),
        radius = 14f,
        center = Offset(centerX + 2f, centerY + 2f)
    )

    // Center pivot - main
    drawCircle(
        color = pivotColor,
        radius = 12f,
        center = Offset(centerX, centerY)
    )

    // Center pivot - highlight
    drawCircle(
        color = Color.White.copy(alpha = 0.3f),
        radius = 6f,
        center = Offset(centerX - 3f, centerY - 3f)
    )
}
