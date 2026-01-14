package com.emfmeter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import com.emfmeter.ui.screens.MainScreen
import com.emfmeter.ui.theme.EMFMeterTheme
import com.emfmeter.viewmodel.EMFViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            val viewModel: EMFViewModel = hiltViewModel()
            val uiState by viewModel.uiState.collectAsState()

            val darkTheme = when (uiState.theme) {
                "dark" -> true
                "light" -> false
                else -> isSystemInDarkTheme()
            }

            EMFMeterTheme(darkTheme = darkTheme) {
                MainScreen(viewModel = viewModel)
            }
        }
    }
}
