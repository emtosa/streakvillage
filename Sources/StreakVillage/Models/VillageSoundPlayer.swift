import AVFoundation
import SwiftUI

/// Procedural synthesised tones for StreakVillage — no audio files required.
@MainActor
final class VillageSoundPlayer {
    static let shared = VillageSoundPlayer()

    @AppStorage("villageSoundMuted") var isMuted = false

    private let engine = AVAudioEngine()
    private let mixer  = AVAudioMixerNode()
    private let rate: Double = 44100

    private init() {
        engine.attach(mixer)
        engine.connect(mixer, to: engine.mainMixerNode,
                       format: AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1))
        try? engine.start()
    }

    /// Soft placement thud followed by a chime — building placed.
    func playBuildingPlaced() {
        play([(110.0, 0.00), (880.0, 0.08), (1108.73, 0.20)], amp: 0.35, dur: 0.20)
    }

    /// Higher chime run — milestone reached.
    func playMilestone() {
        play([(523.25, 0.00), (783.99, 0.12),
              (1046.5, 0.25), (1318.5, 0.38)], amp: 0.38, dur: 0.28)
    }

    // MARK: - Private

    private func play(_ notes: [(Double, Double)], amp: Float, dur: Double) {
        guard !isMuted else { return }
        for (freq, delay) in notes {
            if delay == 0 {
                tone(freq, amp: amp, dur: dur)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.tone(freq, amp: amp, dur: dur)
                }
            }
        }
    }

    private func tone(_ frequency: Double, amp: Float, dur: Double) {
        let count = Int(rate * dur)
        let fmt = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1)!
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt,
                                        frameCapacity: AVAudioFrameCount(count)) else { return }
        buf.frameLength = AVAudioFrameCount(count)
        let d = buf.floatChannelData![0]
        for i in 0..<count {
            let t = Double(i) / rate
            let attack  = Float(min(t / 0.006, 1.0))
            let decay   = Float(max(0, 1.0 - max(0, t - 0.02) / (dur - 0.02)))
            d[i] = Float(sin(2 * .pi * frequency * t)) * amp * attack * decay
        }
        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: mixer, format: fmt)
        node.scheduleBuffer(buf) { [weak self] in
            DispatchQueue.main.async { self?.engine.detach(node) }
        }
        node.play()
    }
}
