//
//  AudioPlayer.swift
//  Music Room
//
//  Created by Nathan Bechon on 03/04/2025.
//

import SwiftUI
import AVFoundation
import Combine

class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    private var player: AVPlayer?

    func playPreview(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }

    func stop() {
        player?.pause()
        player = nil
    }
}
