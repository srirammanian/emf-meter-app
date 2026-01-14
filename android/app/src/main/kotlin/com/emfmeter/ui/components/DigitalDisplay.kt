package com.emfmeter.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.emfmeter.domain.EMFUnit
import com.emfmeter.ui.theme.EMFMeterTheme
import com.emfmeter.util.UnitConverter

/**
 * Digital display component showing EMF readings in LCD calculator style.
 */
@Composable
fun DigitalDisplay(
    value: Float,
    unit: EMFUnit,
    modifier: Modifier = Modifier
) {
    val meterColors = EMFMeterTheme.meterColors
    val formattedValue = UnitConverter.formatValue(value, unit)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        // Outer frame (device housing)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(
                            Color(0xFF4A4A4A),
                            Color(0xFF3A3A3A),
                            Color(0xFF2A2A2A)
                        )
                    )
                )
                .border(
                    width = 2.dp,
                    color = Color(0xFF1A1A1A),
                    shape = RoundedCornerShape(12.dp)
                )
                .padding(16.dp)
        ) {
            // LCD screen
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(4.dp))
                    .background(
                        brush = Brush.verticalGradient(
                            colors = listOf(
                                meterColors.digitalBackground.copy(alpha = 0.95f),
                                meterColors.digitalBackground,
                                meterColors.digitalBackground.copy(alpha = 0.9f)
                            )
                        )
                    )
                    .border(
                        width = 3.dp,
                        color = Color(0xFF111111),
                        shape = RoundedCornerShape(4.dp)
                    )
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    // Shadow digits (background segments)
                    Box {
                        // Background "off" segments
                        Text(
                            text = "8".repeat(formattedValue.replace(".", "").length) +
                                    if (formattedValue.contains(".")) "." else "",
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                            fontSize = 72.sp,
                            letterSpacing = 8.sp,
                            color = meterColors.digitalSegmentOff
                        )

                        // Active digits
                        Text(
                            text = formattedValue,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Bold,
                            fontSize = 72.sp,
                            letterSpacing = 8.sp,
                            color = meterColors.digitalText
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))

                    // Unit display
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.Center
                    ) {
                        Text(
                            text = unit.symbol,
                            fontFamily = FontFamily.Monospace,
                            fontWeight = FontWeight.Medium,
                            fontSize = 28.sp,
                            color = meterColors.digitalText.copy(alpha = 0.9f)
                        )

                        Spacer(modifier = Modifier.width(16.dp))

                        // Small indicator dots
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            IndicatorDot(
                                active = true,
                                color = meterColors.digitalText
                            )
                            IndicatorDot(
                                active = value > 0f,
                                color = meterColors.digitalText
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun IndicatorDot(
    active: Boolean,
    color: Color,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .width(8.dp)
            .height(8.dp)
            .clip(RoundedCornerShape(4.dp))
            .background(
                color = if (active) color else color.copy(alpha = 0.2f)
            )
    )
}
