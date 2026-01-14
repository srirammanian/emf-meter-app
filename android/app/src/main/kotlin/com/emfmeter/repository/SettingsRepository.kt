package com.emfmeter.repository

import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import com.emfmeter.domain.CalibrationData
import com.emfmeter.domain.DisplayMode
import com.emfmeter.domain.EMFUnit
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

/**
 * Repository for persisting user settings.
 */
class SettingsRepository @Inject constructor(
    private val dataStore: DataStore<Preferences>
) {
    companion object {
        private val UNIT_KEY = stringPreferencesKey("selected_unit")
        private val SOUND_ENABLED_KEY = booleanPreferencesKey("sound_enabled")
        private val DISPLAY_MODE_KEY = stringPreferencesKey("display_mode")
        private val THEME_KEY = stringPreferencesKey("theme")

        private val CALIBRATION_X_KEY = floatPreferencesKey("calibration_x")
        private val CALIBRATION_Y_KEY = floatPreferencesKey("calibration_y")
        private val CALIBRATION_Z_KEY = floatPreferencesKey("calibration_z")
        private val CALIBRATION_TIMESTAMP_KEY = longPreferencesKey("calibration_timestamp")
    }

    // Unit preference
    val selectedUnit: Flow<EMFUnit> = dataStore.data.map { prefs ->
        val name = prefs[UNIT_KEY] ?: EMFUnit.DEFAULT.name
        EMFUnit.fromName(name) ?: EMFUnit.DEFAULT
    }

    suspend fun saveUnit(unit: EMFUnit) {
        dataStore.edit { prefs ->
            prefs[UNIT_KEY] = unit.name
        }
    }

    // Sound preference
    val soundEnabled: Flow<Boolean> = dataStore.data.map { prefs ->
        prefs[SOUND_ENABLED_KEY] ?: true
    }

    suspend fun saveSoundEnabled(enabled: Boolean) {
        dataStore.edit { prefs ->
            prefs[SOUND_ENABLED_KEY] = enabled
        }
    }

    // Display mode preference
    val displayMode: Flow<DisplayMode> = dataStore.data.map { prefs ->
        val name = prefs[DISPLAY_MODE_KEY] ?: DisplayMode.ANALOG.name
        try {
            DisplayMode.valueOf(name)
        } catch (e: IllegalArgumentException) {
            DisplayMode.ANALOG
        }
    }

    suspend fun saveDisplayMode(mode: DisplayMode) {
        dataStore.edit { prefs ->
            prefs[DISPLAY_MODE_KEY] = mode.name
        }
    }

    // Theme preference
    val theme: Flow<String> = dataStore.data.map { prefs ->
        prefs[THEME_KEY] ?: "system"
    }

    suspend fun saveTheme(theme: String) {
        dataStore.edit { prefs ->
            prefs[THEME_KEY] = theme
        }
    }

    // Calibration data
    val calibrationData: Flow<CalibrationData> = dataStore.data.map { prefs ->
        CalibrationData(
            offsetX = prefs[CALIBRATION_X_KEY] ?: 0f,
            offsetY = prefs[CALIBRATION_Y_KEY] ?: 0f,
            offsetZ = prefs[CALIBRATION_Z_KEY] ?: 0f,
            timestamp = prefs[CALIBRATION_TIMESTAMP_KEY] ?: 0L
        )
    }

    suspend fun saveCalibration(data: CalibrationData) {
        dataStore.edit { prefs ->
            prefs[CALIBRATION_X_KEY] = data.offsetX
            prefs[CALIBRATION_Y_KEY] = data.offsetY
            prefs[CALIBRATION_Z_KEY] = data.offsetZ
            prefs[CALIBRATION_TIMESTAMP_KEY] = data.timestamp
        }
    }

    suspend fun clearCalibration() {
        dataStore.edit { prefs ->
            prefs.remove(CALIBRATION_X_KEY)
            prefs.remove(CALIBRATION_Y_KEY)
            prefs.remove(CALIBRATION_Z_KEY)
            prefs.remove(CALIBRATION_TIMESTAMP_KEY)
        }
    }
}
