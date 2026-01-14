package com.emfmeter.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.emfmeter.R
import com.emfmeter.domain.DisplayMode
import com.emfmeter.ui.components.AnalogMeter
import com.emfmeter.ui.components.ControlButtons
import com.emfmeter.ui.components.DigitalDisplay
import com.emfmeter.ui.components.ModeToggle
import com.emfmeter.util.UnitConverter
import com.emfmeter.viewmodel.EMFViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    viewModel: EMFViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val lifecycleOwner = LocalLifecycleOwner.current

    // Handle lifecycle events
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_START -> viewModel.onStart()
                Lifecycle.Event.ON_STOP -> viewModel.onStop()
                else -> {}
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize()
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.background)
                .padding(paddingValues)
        ) {
            if (!uiState.sensorAvailable) {
                // Sensor not available message
                SensorUnavailableMessage()
            } else {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // App title
                    Text(
                        text = stringResource(R.string.app_name),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onBackground,
                        modifier = Modifier.padding(top = 16.dp)
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    // Current value display
                    Text(
                        text = "${UnitConverter.formatValue(uiState.displayValue, uiState.selectedUnit)} ${uiState.selectedUnit.symbol}",
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )

                    Spacer(modifier = Modifier.weight(0.1f))

                    // Meter display (Analog or Digital)
                    AnimatedContent(
                        targetState = uiState.displayMode,
                        transitionSpec = {
                            fadeIn() togetherWith fadeOut()
                        },
                        label = "meterDisplay",
                        modifier = Modifier.weight(1f)
                    ) { mode ->
                        when (mode) {
                            DisplayMode.ANALOG -> {
                                AnalogMeter(
                                    needlePosition = uiState.needlePosition,
                                    unit = uiState.selectedUnit,
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                            DisplayMode.DIGITAL -> {
                                DigitalDisplay(
                                    value = uiState.displayValue,
                                    unit = uiState.selectedUnit,
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.weight(0.1f))

                    // Mode toggle
                    ModeToggle(
                        currentMode = uiState.displayMode,
                        onModeChange = { viewModel.setDisplayMode(it) }
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Control buttons
                    ControlButtons(
                        soundEnabled = uiState.soundEnabled,
                        isCalibrated = uiState.isCalibrated,
                        onSoundToggle = { viewModel.toggleSound() },
                        onCalibrate = { viewModel.calibrate() },
                        onSettingsClick = { viewModel.showSettings(true) }
                    )

                    Spacer(modifier = Modifier.height(24.dp))
                }
            }

            // Settings bottom sheet
            if (uiState.showSettings) {
                ModalBottomSheet(
                    onDismissRequest = { viewModel.showSettings(false) },
                    sheetState = rememberModalBottomSheetState()
                ) {
                    SettingsScreen(
                        selectedUnit = uiState.selectedUnit,
                        selectedTheme = uiState.theme,
                        isCalibrated = uiState.isCalibrated,
                        onUnitChange = { viewModel.setUnit(it) },
                        onThemeChange = { viewModel.setTheme(it) },
                        onResetCalibration = { viewModel.resetCalibration() },
                        onDismiss = { viewModel.showSettings(false) }
                    )
                }
            }
        }
    }
}

@Composable
private fun SensorUnavailableMessage() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(32.dp)
        ) {
            Text(
                text = "⚠️",
                fontSize = 64.sp
            )
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = stringResource(R.string.sensor_unavailable),
                style = MaterialTheme.typography.titleLarge,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.error
            )
        }
    }
}
