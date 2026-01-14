package com.emfmeter.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.emfmeter.data.CalibrationManager
import com.emfmeter.data.EMFProcessor
import com.emfmeter.data.NeedlePhysicsEngine
import com.emfmeter.domain.CalibrationData
import com.emfmeter.domain.DisplayMode
import com.emfmeter.domain.EMFUnit
import com.emfmeter.domain.MeterConfig
import com.emfmeter.domain.ProcessedReading
import com.emfmeter.repository.SettingsRepository
import com.emfmeter.service.AudioService
import com.emfmeter.service.MagnetometerService
import com.emfmeter.util.UnitConverter
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * UI state for the EMF Meter.
 */
data class EMFUiState(
    val currentReading: ProcessedReading? = null,
    val needlePosition: Float = 0f,
    val displayValue: Float = 0f,
    val displayMode: DisplayMode = DisplayMode.ANALOG,
    val selectedUnit: EMFUnit = EMFUnit.MILLI_GAUSS,
    val soundEnabled: Boolean = true,
    val isCalibrated: Boolean = false,
    val sensorAvailable: Boolean = true,
    val showSettings: Boolean = false,
    val theme: String = "system"
)

@HiltViewModel
class EMFViewModel @Inject constructor(
    private val magnetometerService: MagnetometerService,
    private val audioService: AudioService,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val calibrationManager = CalibrationManager()
    private val emfProcessor = EMFProcessor(calibrationManager)
    private val needlePhysics = NeedlePhysicsEngine()

    private val _uiState = MutableStateFlow(EMFUiState())
    val uiState: StateFlow<EMFUiState> = _uiState.asStateFlow()

    private var needleUpdateJob: Job? = null

    init {
        loadSettings()
        observeReadings()
        startNeedleAnimation()

        _uiState.update {
            it.copy(sensorAvailable = magnetometerService.isAvailable)
        }
    }

    private fun loadSettings() {
        viewModelScope.launch {
            // Load all saved settings
            val unit = settingsRepository.selectedUnit.first()
            val soundEnabled = settingsRepository.soundEnabled.first()
            val displayMode = settingsRepository.displayMode.first()
            val theme = settingsRepository.theme.first()
            val calibration = settingsRepository.calibrationData.first()

            if (calibration.isCalibrated) {
                calibrationManager.restore(calibration)
            }

            _uiState.update { state ->
                state.copy(
                    selectedUnit = unit,
                    soundEnabled = soundEnabled,
                    displayMode = displayMode,
                    theme = theme,
                    isCalibrated = calibration.isCalibrated
                )
            }

            audioService.setEnabled(soundEnabled)
        }
    }

    private fun observeReadings() {
        viewModelScope.launch {
            magnetometerService.readings.collect { reading ->
                val processed = emfProcessor.process(reading)

                _uiState.update { state ->
                    val displayValue = UnitConverter.convert(
                        processed.magnitude,
                        EMFUnit.MICRO_TESLA,
                        state.selectedUnit
                    )

                    state.copy(
                        currentReading = processed,
                        displayValue = displayValue
                    )
                }

                // Play click sound if in analog mode with sound enabled
                val state = _uiState.value
                if (state.soundEnabled && state.displayMode == DisplayMode.ANALOG) {
                    audioService.playClickIfNeeded(processed.normalizedValue)
                }
            }
        }
    }

    private fun startNeedleAnimation() {
        needleUpdateJob = viewModelScope.launch {
            val frameTime = 1000L / MeterConfig.DISPLAY_REFRESH_HZ
            while (isActive) {
                val targetPosition = _uiState.value.currentReading?.normalizedValue ?: 0f
                val newPosition = needlePhysics.update(
                    targetPosition,
                    deltaTime = 1f / MeterConfig.DISPLAY_REFRESH_HZ
                )

                _uiState.update { it.copy(needlePosition = newPosition) }
                delay(frameTime)
            }
        }
    }

    fun setDisplayMode(mode: DisplayMode) {
        _uiState.update { it.copy(displayMode = mode) }
        viewModelScope.launch {
            settingsRepository.saveDisplayMode(mode)
        }
    }

    fun setUnit(unit: EMFUnit) {
        _uiState.update { state ->
            val newDisplayValue = state.currentReading?.let {
                UnitConverter.convert(it.magnitude, EMFUnit.MICRO_TESLA, unit)
            } ?: 0f

            state.copy(
                selectedUnit = unit,
                displayValue = newDisplayValue
            )
        }
        viewModelScope.launch {
            settingsRepository.saveUnit(unit)
        }
    }

    fun toggleSound() {
        val newState = !_uiState.value.soundEnabled
        _uiState.update { it.copy(soundEnabled = newState) }
        audioService.setEnabled(newState)
        viewModelScope.launch {
            settingsRepository.saveSoundEnabled(newState)
        }
    }

    fun calibrate() {
        val currentReading = _uiState.value.currentReading?.rawReading ?: return
        val calibration = calibrationManager.calibrate(currentReading)

        _uiState.update { it.copy(isCalibrated = true) }

        viewModelScope.launch {
            settingsRepository.saveCalibration(calibration)
        }
    }

    fun resetCalibration() {
        calibrationManager.reset()
        _uiState.update { it.copy(isCalibrated = false) }
        viewModelScope.launch {
            settingsRepository.clearCalibration()
        }
    }

    fun setTheme(theme: String) {
        _uiState.update { it.copy(theme = theme) }
        viewModelScope.launch {
            settingsRepository.saveTheme(theme)
        }
    }

    fun showSettings(show: Boolean) {
        _uiState.update { it.copy(showSettings = show) }
    }

    fun onStart() {
        magnetometerService.start()
    }

    fun onStop() {
        magnetometerService.stop()
    }

    override fun onCleared() {
        super.onCleared()
        needleUpdateJob?.cancel()
        magnetometerService.stop()
        audioService.release()
    }
}
