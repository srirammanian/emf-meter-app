import Foundation
import AVFoundation

/// Service for playing Geiger counter click sounds.
class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var lastClickTime: Date = .distantPast

    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                audioPlayer?.stop()
            }
        }
    }

    init() {
        setupAudio()
    }

    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "geiger_click", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.5
        } catch {
            print("Audio setup failed: \(error)")
        }
    }

    /// Check if a click should be played and play it if needed.
    func playClickIfNeeded(normalizedValue: Float) {
        guard isEnabled else { return }

        let now = Date()
        let timeSinceLastClick = now.timeIntervalSince(lastClickTime)

        if SoundClickCalculator.shouldPlayClick(
            normalizedValue: normalizedValue,
            timeSinceLastClick: timeSinceLastClick
        ) {
            // Play with slight volume variation for realism
            let volume = 0.4 + (normalizedValue * 0.3)
            audioPlayer?.volume = volume

            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
            lastClickTime = now
        }
    }
}
