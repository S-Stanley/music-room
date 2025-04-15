//
//  PlaylistViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 14/04/2025.
//

import Foundation

class PlaylistViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var playlistTracks: Set<String> = []
    private var currentTrackIndex: Int = 0
    var associatedUUIDs: [String: String] = [:]
    @Published var errorMessage: String?
    private var isPlaying = false
    private var audioPlayer = AudioPlayer.shared
    private var hasStartedPlaying = false
    var playlistId: String
    
    init(playlistId: String) {
            self.playlistId = playlistId
        }
    
    func fetchTracksForPlaylist(playlistId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let user = User.load() else {
            completion(false, "Utilisateur non authentifié")
            return
        }

        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/track") else {
            completion(false, "URL invalide")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(user.token, forHTTPHeaderField: "token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur de requête: \(error.localizedDescription)")
                    completion(false, "Erreur: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    print("❌ Réponse invalide du serveur")
                    completion(false, "Réponse invalide du serveur")
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Ajout de l'affichage de la réponse brute
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Réponse brute de l'API : \(dataString)")
                    }

                    do {
                        let playlistTracks = try JSONDecoder().decode([PlaylistTrack].self, from: data)
                        self.tracks = playlistTracks.map {
                            Track(
                                id: Int($0.trackId) ?? 0,
                                title: $0.trackTitle,
                                link: "",
                                duration: 0,
                                rank: 0,
                                preview: $0.trackPreview,
                                album: Album(id: 0, title: "", cover: $0.albumCover, coverSmall: $0.albumCover, coverMedium: $0.albumCover, coverBig: $0.albumCover, coverXL: $0.albumCover, tracklist: ""),
                                artist: Artist(id: 0, name: "", link: "", picture: "", pictureSmall: "", pictureMedium: "", pictureBig: "", pictureXL: ""),
                                uuid: $0.id,
                                voteCount: $0.votes
                            )
                        }
                        
                        for track in self.tracks {
                            print("Track \(track.id) voteCount: \(track.voteCount ?? 0)")
                        }

                        self.playlistTracks = Set(playlistTracks.map { $0.trackId })

                        for track in playlistTracks {
                            self.associatedUUIDs[track.trackId] = track.id
                        }
                        
                        print("Contenu de associatedUUIDs après fetchTracksForPlaylist : \(self.associatedUUIDs)")
                    
                        completion(true, nil)
                        self.startAutomaticPlaybackIfNeeded()
                    } catch {
                        print("❌ Erreur de décodage JSON: \(error.localizedDescription)")
                        completion(false, "Erreur de décodage JSON")
                    }
                } else {
                    print("❌ Erreur serveur: \(httpResponse.statusCode)")
                    completion(false, "Erreur serveur (\(httpResponse.statusCode))")
                }
            }
        }.resume()
    }
    
    func voteForTrack(track: Track, playlistId: String) {
        guard let uuid = track.uuid else {
            print("❌ Pas d’UUID pour ce morceau : \(track.title)")
            return
        }
        print("\(uuid)")
        print("\(playlistId)")
        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/vote/\(uuid)") else {
            print("❌ URL invalide")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let user = User.load() {
            request.setValue(user.token, forHTTPHeaderField: "token")
        } else {
            print("❌ Utilisateur non authentifié")
            return
        }
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Corps de la requête : \(bodyString)")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur vote: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 201:
                        print("✅ Vote enregistré pour \(track.title)")
                        self.hasStartedPlaying = true
                        self.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                            if success {
                                print("✅ Pistes de la playlist mises à jour après le vote")
                                // Les données seront automatiquement mises à jour dans l'interface utilisateur
                            } else {
                                print("❌ Erreur lors de la mise à jour des pistes après le vote : \(error ?? "Inconnue")")
                            }
                        }
                    case 400:
                        print("❌ Mauvaise requête : déjà voté ou données invalides")
                    case 401:
                        print("❌ Non autorisé")
                    default:
                        print("❌ Erreur serveur: \(httpResponse.statusCode)")
                    }
                }
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse : \(responseString)")
                }
            }
        }.resume()
    }
    
    func markTrackAsPlayed(trackId: String) {
             // Récupérer l'UUID associé à ce trackId
             guard let trackUUID = associatedUUIDs[trackId] else {
                 print("❌ Aucun UUID trouvé pour ce trackId")
                 return
             }
            associatedUUIDs[trackId] = nil
             guard let url = URL(string: "http://localhost:5001/track/\(trackUUID)/played") else {
                 self.errorMessage = "URL invalide pour PATCH"
                 return
             }
     
             var request = URLRequest(url: url)
             request.httpMethod = "PATCH"
     
             if let user = User.load() {
                 request.setValue(user.token, forHTTPHeaderField: "token")
             } else {
                 self.errorMessage = "Utilisateur non authentifié"
                 return
             }
     
             URLSession.shared.dataTask(with: request) { data, response, error in
                 DispatchQueue.main.async {
                     if let error = error {
                         print("❌ Erreur PATCH: \(error.localizedDescription)")
                         return
                     }
     
                     guard let httpResponse = response as? HTTPURLResponse else {
                         print("❌ Réponse PATCH invalide")
                         return
                     }
     
                     switch httpResponse.statusCode {
                         case 200:
                             print("✅ Track \(trackUUID) marqué comme joué")
                         case 400:
                             print("⚠️ Track non trouvé")
                         case 500:
                             print("🔥 Erreur serveur")
                         default:
                             print("❓ Code inconnu: \(httpResponse.statusCode)")
                     }
                 }
             }.resume()
         }
    
    private func playFirstTrack() {
        // Cas où la playlist est vide
        guard !tracks.isEmpty else {
            print("🎶 Playlist vide — arrêt")
            isPlaying = false
            return
        }

        let track = tracks[0]
        isPlaying = true
        
        // Appel pour jouer le premier morceau et appeler fetchTracksForPlaylist après
        audioPlayer.playPreview(from: track.preview) { [weak self] in
            guard let self = self else { return }

            print("✅ Fin de : \(track.title)")

            // Marquer le morceau comme joué
            self.markTrackAsPlayed(trackId: String(track.id))

            // Rafraîchir la playlist avant de jouer le prochain morceau
            self.fetchTracksForPlaylist(playlistId: self.playlistId) { success, error in
                if success {
                    // Playlist mise à jour, passer au morceau suivant
                    if !self.tracks.isEmpty {
                        self.playFirstTrack()
                    } else {
                        print("🏁 Fin de la playlist")
                        self.isPlaying = false
                    }
                } else {
                    print("❌ Erreur lors de la mise à jour de la playlist : \(error ?? "Inconnue")")
                    self.isPlaying = false
                }
            }
        }
    }
    
    private func startAutomaticPlaybackIfNeeded() {
            if !isPlaying && !hasStartedPlaying && !tracks.isEmpty {
                hasStartedPlaying = true
                playFirstTrack()
            }
        }
}
