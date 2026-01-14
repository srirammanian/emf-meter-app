package com.emfmeter.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = Primary,
    onPrimary = OnPrimary,
    primaryContainer = PrimaryVariant,
    background = BackgroundLight,
    onBackground = OnBackgroundLight,
    surface = SurfaceLight,
    onSurface = OnSurfaceLight,
    surfaceVariant = MeterBezelLight,
    onSurfaceVariant = MeterScaleLight
)

private val DarkColorScheme = darkColorScheme(
    primary = AccentDark,
    onPrimary = OnPrimary,
    primaryContainer = Primary,
    background = BackgroundDark,
    onBackground = OnBackgroundDark,
    surface = SurfaceDark,
    onSurface = OnSurfaceDark,
    surfaceVariant = MeterBezelDark,
    onSurfaceVariant = MeterScaleDark
)

data class MeterColors(
    val bezel: Color,
    val face: Color,
    val scale: Color,
    val needle: Color,
    val pivot: Color,
    val digitalBackground: Color,
    val digitalText: Color,
    val digitalSegmentOff: Color,
    val digitalBorder: Color
)

val LocalMeterColors = staticCompositionLocalOf {
    MeterColors(
        bezel = MeterBezelLight,
        face = MeterFaceLight,
        scale = MeterScaleLight,
        needle = MeterNeedleLight,
        pivot = MeterPivotLight,
        digitalBackground = DigitalBackground,
        digitalText = DigitalText,
        digitalSegmentOff = DigitalSegmentOff,
        digitalBorder = DigitalBorder
    )
}

@Composable
fun EMFMeterTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val meterColors = if (darkTheme) {
        MeterColors(
            bezel = MeterBezelDark,
            face = MeterFaceDark,
            scale = MeterScaleDark,
            needle = MeterNeedleDark,
            pivot = MeterPivotDark,
            digitalBackground = DigitalBackgroundDark,
            digitalText = DigitalText,
            digitalSegmentOff = DigitalSegmentOff,
            digitalBorder = DigitalBorder
        )
    } else {
        MeterColors(
            bezel = MeterBezelLight,
            face = MeterFaceLight,
            scale = MeterScaleLight,
            needle = MeterNeedleLight,
            pivot = MeterPivotLight,
            digitalBackground = DigitalBackground,
            digitalText = DigitalText,
            digitalSegmentOff = DigitalSegmentOff,
            digitalBorder = DigitalBorder
        )
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primaryContainer.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    CompositionLocalProvider(LocalMeterColors provides meterColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}

object EMFMeterTheme {
    val meterColors: MeterColors
        @Composable
        get() = LocalMeterColors.current
}
