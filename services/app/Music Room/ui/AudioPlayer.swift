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
    private var currentItem: AVPlayerItem?

    func playPreview(from urlString: String, onFinished: @escaping () -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ URL invalide pour le preview")
            return
        }

        // 🔁 Supprime observer précédent proprement
        if let currentItem = currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }

        // 🛑 Arrête la lecture actuelle
        player?.pause()
        player = nil

        // 🎧 Nouveau morceau
        let item = AVPlayerItem(url: url)
        currentItem = item
        player = AVPlayer(playerItem: item)
        player?.play()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )

        // 👇 Sauvegarde le callback à appeler à la fin
        self.onFinished = onFinished
    }

    private var onFinished: (() -> Void)?

    @objc private func playerDidFinishPlaying() {
        print("🎧 Fin du morceau détectée par AudioPlayer")
        onFinished?()
        onFinished = nil
    }


    func stop() {
        if let currentItem = currentItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }

        player?.pause()
        player = nil
        currentItem = nil
        onFinished = nil
    }
    
    

}
