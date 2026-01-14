package com.emfmeter.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.emfmeter.R
import com.emfmeter.domain.EMFUnit

@Composable
fun SettingsScreen(
    selectedUnit: EMFUnit,
    selectedTheme: String,
    isCalibrated: Boolean,
    onUnitChange: (EMFUnit) -> Unit,
    onThemeChange: (String) -> Unit,
    onResetCalibration: () -> Unit,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp)
            .padding(bottom = 32.dp)
    ) {
        // Title
        Text(
            text = stringResource(R.string.settings),
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Unit selection
        SettingsSection(title = stringResource(R.string.unit_selection)) {
            Column {
                UnitOption(
                    label = stringResource(R.string.unit_milligauss),
                    selected = selectedUnit == EMFUnit.MILLI_GAUSS,
                    onClick = { onUnitChange(EMFUnit.MILLI_GAUSS) }
                )
                UnitOption(
                    label = stringResource(R.string.unit_microtesla),
                    selected = selectedUnit == EMFUnit.MICRO_TESLA,
                    onClick = { onUnitChange(EMFUnit.MICRO_TESLA) }
                )
                UnitOption(
                    label = stringResource(R.string.unit_gauss),
                    selected = selectedUnit == EMFUnit.GAUSS,
                    onClick = { onUnitChange(EMFUnit.GAUSS) }
                )
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))

        // Theme selection
        SettingsSection(title = stringResource(R.string.theme_selection)) {
            Column {
                ThemeOption(
                    label = stringResource(R.string.theme_system),
                    selected = selectedTheme == "system",
                    onClick = { onThemeChange("system") }
                )
                ThemeOption(
                    label = stringResource(R.string.theme_light),
                    selected = selectedTheme == "light",
                    onClick = { onThemeChange("light") }
                )
                ThemeOption(
                    label = stringResource(R.string.theme_dark),
                    selected = selectedTheme == "dark",
                    onClick = { onThemeChange("dark") }
                )
            }
        }

        HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))

        // Calibration reset
        SettingsSection(title = stringResource(R.string.calibrate)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (isCalibrated) {
                        stringResource(R.string.calibration_success)
                    } else {
                        "Not calibrated"
                    },
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (isCalibrated) {
                        MaterialTheme.colorScheme.primary
                    } else {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    }
                )

                if (isCalibrated) {
                    Button(
                        onClick = onResetCalibration,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.errorContainer,
                            contentColor = MaterialTheme.colorScheme.onErrorContainer
                        )
                    ) {
                        Text(text = stringResource(R.string.reset_calibration))
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Disclaimer
        Text(
            text = stringResource(R.string.disclaimer_text),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 8.dp)
        )

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun SettingsSection(
    title: String,
    content: @Composable () -> Unit
) {
    Column {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.padding(bottom = 12.dp)
        )
        content()
    }
}

@Composable
private fun UnitOption(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    OptionRow(
        label = label,
        selected = selected,
        onClick = onClick
    )
}

@Composable
private fun ThemeOption(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    OptionRow(
        label = label,
        selected = selected,
        onClick = onClick
    )
}

@Composable
private fun OptionRow(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(vertical = 12.dp, horizontal = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyLarge,
            color = if (selected) {
                MaterialTheme.colorScheme.primary
            } else {
                MaterialTheme.colorScheme.onSurface
            }
        )

        if (selected) {
            Icon(
                imageVector = Icons.Default.Check,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary
            )
        }
    }
}
