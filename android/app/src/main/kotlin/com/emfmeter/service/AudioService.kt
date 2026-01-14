package com.emfmeter.service

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import com.emfmeter.R
import com.emfmeter.util.SoundClickCalculator
import javax.inject.Inject

/**
 * Service for playing Geiger counter click sounds.
 * Click frequency increases with EMF intensity.
 */
class AudioService @Inject constructor(
    context: Context
) {
    private val soundPool: SoundPool = SoundPool.Builder()
        .setMaxStreams(4)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()

    private var clickSoundId: Int = 0
    private var isLoaded = false
    private var isEnabled = true
    private var lastClickTime: Long = 0

    init {
        clickSoundId = soundPool.load(context, R.raw.geiger_click, 1)
        soundPool.setOnLoadCompleteListener { _, _, status ->
            isLoaded = (status == 0)
        }
    }

    /**
     * Check if a click should be played based on current EMF value,
     * and play it if needed.
     *
     * @param normalizedValue EMF reading normalized to 0.0-1.0 range
     */
    fun playClickIfNeeded(normalizedValue: Float) {
        if (!isEnabled || !isLoaded) return

        val now = System.currentTimeMillis()
        val timeSinceLastClick = now - lastClickTime

        if (SoundClickCalculator.shouldPlayClick(normalizedValue, timeSinceLastClick)) {
            // Play with slight volume and pitch variation for realism
            val volume = 0.4f + (normalizedValue * 0.3f)
            val pitch = 0.95f + (Math.random().toFloat() * 0.1f)

            soundPool.play(clickSoundId, volume, volume, 1, 0, pitch)
            lastClickTime = now
        }
    }

    /**
     * Enable or disable sound playback.
     */
    fun setEnabled(enabled: Boolean) {
        isEnabled = enabled
    }

    /**
     * Release audio resources.
     */
    fun release() {
        soundPool.release()
    }
}
