import Foundation
import AVFoundation

/// Service for playing Geiger counter click sounds and UI sounds.
/// Uses a pool of audio players to support rapid overlapping clicks.
class AudioService: ObservableObject {
    private var audioPlayers: [AVAudioPlayer] = []
    private var currentPlayerIndex: Int = 0
    private var lastClickTime: Date = .distantPast
    private let playerPoolSize = 4  // Pool of players for overlapping sounds

    // Switch sound player (for UI feedback)
    private var switchPlayer: AVAudioPlayer?

    @Published var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                audioPlayers.forEach { $0.stop() }
            }
        }
    }

    init() {
        setupAudio()
        setupSwitchSound()
    }

    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "geiger_click", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            // Create a pool of audio players for overlapping playback
            for _ in 0..<playerPoolSize {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = 0.5
                audioPlayers.append(player)
            }
        } catch {
            print("Audio setup failed: \(error)")
        }
    }

    private func setupSwitchSound() {
        guard let url = Bundle.main.url(forResource: "switch", withExtension: "mp3") else {
            print("Switch audio file not found")
            return
        }

        do {
            switchPlayer = try AVAudioPlayer(contentsOf: url)
            switchPlayer?.prepareToPlay()
            switchPlayer?.volume = 0.6
        } catch {
            print("Switch audio setup failed: \(error)")
        }
    }

    /// Play the switch toggle sound (always plays, regardless of isEnabled).
    func playSwitch() {
        switchPlayer?.currentTime = 0
        switchPlayer?.play()
    }

    /// Check if a click should be played and play it if needed.
    func playClickIfNeeded(normalizedValue: Float) {
        guard isEnabled, !audioPlayers.isEmpty else { return }

        let now = Date()
        let timeSinceLastClick = now.timeIntervalSince(lastClickTime)

        if SoundClickCalculator.shouldPlayClick(
            normalizedValue: normalizedValue,
            timeSinceLastClick: timeSinceLastClick
        ) {
            // Play with slight volume variation for realism (quieter overall)
            let volume = 0.15 + (normalizedValue * 0.15)

            // Use next player in the pool (round-robin)
            let player = audioPlayers[currentPlayerIndex]
            currentPlayerIndex = (currentPlayerIndex + 1) % playerPoolSize

            player.volume = volume
            player.currentTime = 0
            player.play()

            lastClickTime = now
        }
    }
}
