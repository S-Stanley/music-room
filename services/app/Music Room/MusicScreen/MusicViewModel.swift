//
//  MusicViewModel.swift
//  Music Room
//
//  Created by Nathan Bechon on 24/03/2025.
//

import Foundation

struct Artist: Codable {
    let id: Int
    let name: String
    let link: String
    let picture: String
    let pictureSmall: String
    let pictureMedium: String
    let pictureBig: String
    let pictureXL: String

    enum CodingKeys: String, CodingKey {
        case id, name, link, picture
        case pictureSmall = "picture_small"
        case pictureMedium = "picture_medium"
        case pictureBig = "picture_big"
        case pictureXL = "picture_xl"
    }
}

struct Album: Codable {
    let id: Int
    let title: String
    let cover: String
    let coverSmall: String
    let coverMedium: String
    let coverBig: String
    let coverXL: String
    let tracklist: String

    enum CodingKeys: String, CodingKey {
        case id, title, cover, tracklist
        case coverSmall = "cover_small"
        case coverMedium = "cover_medium"
        case coverBig = "cover_big"
        case coverXL = "cover_xl"
    }
}

struct Track: Codable {
    let id: Int
    let title: String
    let link: String
    let duration: Int
    let rank: Int
    let preview: String
    let album: Album
    let artist: Artist

    enum CodingKeys: String, CodingKey {
        case id, title, link, duration, rank, preview, album, artist
    }
}

struct PlaylistTrack: Codable, Identifiable {
    let id: String
    let trackId: String
    let trackTitle: String
    let trackPreview: String
    let albumCover: String
    let userId: String
    let playlistId: String
    let position: Int
    let createdAt: String
    let updatedAt: String
}


class MusicViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var errorMessage: String?
    @Published var searchedTracks: [Track] = []
    @Published var playlistTracks: Set<String> = []
    
    private var currentTrackIndex: Int = 0
    private var audioPlayer = AudioPlayer.shared
    private var isPlaying = false
    private var hasStartedPlaying = false
    
    var associatedUUIDs: [String: String] = [:]

    func searchMusic(query: String) {
            guard let url = URL(string: "http://localhost:5001/track/search?q=\(query)") else {
                self.errorMessage = "URL invalide"
                return
            }
            print("🔎 Recherche envoyée avec query:", query)

            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            if let user = User.load() {
                request.setValue(user.token, forHTTPHeaderField: "token")
            } else {
                self.errorMessage = "Utilisateur non authentifié"
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Erreur: \(error.localizedDescription)"
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                        self.errorMessage = "Réponse invalide du serveur"
                        return
                    }

                    if httpResponse.statusCode == 200 {
                        do {
                            let decodedResponse = try JSONDecoder().decode([Track].self, from: data)
                            self.searchedTracks = decodedResponse // 🔥 Stocker les résultats ici !
                        } catch {
                            self.errorMessage = "Erreur lors du décodage de la réponse"
                        }
                    } else {
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
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

    func addMusicToPlaylist(playlistId: String, trackId: String) {
        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)") else {
            self.errorMessage = "URL invalide"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if let user = User.load() {
            request.setValue(user.token, forHTTPHeaderField: "token")
        } else {
            self.errorMessage = "Utilisateur non authentifié"
            print("❌ Aucun utilisateur trouvé dans UserDefaults")
            return
        }

        // Ajouter le trackId au body
        let bodyString = "trackId=\(trackId)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur"
                    return
                }

                // Loguer la réponse brute pour mieux comprendre ce qui est retourné
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📝 Réponse brute de l'API : \(responseString)")
                    }
                }

                switch httpResponse.statusCode {
                    case 201:
                        print("✅ Chanson ajoutée avec succès à la playlist !")

                        // Décoder la réponse et extraire l'UUID
                        if let data = data {
                            do {
                                // Log pour inspecter le format des données
                                print("📝 Tentative de décodage des données JSON")
                                
                                // Essayons de décoder avec un type plus générique pour comprendre le format
                                let decodedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                                
                                // Log pour voir la structure de la réponse
                                print("📝 Réponse décodée : \(decodedResponse)")

                                // Essayer de récupérer l'UUID à partir de la réponse
                                if let responseDict = decodedResponse as? [String: Any], let trackUUID = responseDict["id"] as? String {
                                    self.associatedUUIDs[trackId] = trackUUID
                                    print("✅ UUID associé: \(trackUUID)")
                                } else {
                                    print("❌ UUID non trouvé dans la réponse")
                                }
                            } catch {
                                print("❌ Erreur lors du décodage de la réponse: \(error.localizedDescription)")
                            }
                        }
                    case 400:
                        self.errorMessage = "Erreur: TrackId manquant ou playlist inexistante"
                    case 401:
                        self.errorMessage = "Non autorisé, vérifiez votre token"
                    default:
                        self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                }
            }
        }.resume()
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
                                    artist: Artist(id: 0, name: "", link: "", picture: "", pictureSmall: "", pictureMedium: "", pictureBig: "", pictureXL: "")
                                )
                            }

                            self.playlistTracks = Set(playlistTracks.map { $0.trackId })
                            self.currentTrackIndex = 0
                            
                            // ✅ On lance la lecture une seule fois
                            if !self.tracks.isEmpty && !self.hasStartedPlaying {
                                self.hasStartedPlaying = true
                                self.playNextTrack()
                            }

                            completion(true, nil)
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

    private func playNextTrack() {
        // Nettoyage observer pour éviter les doublons
        NotificationCenter.default.removeObserver(self)

        // Cas où la playlist est vide
        guard !tracks.isEmpty else {
            print("🎶 Playlist vide — arrêt")
            isPlaying = false
            return
        }

        // Sécurité au cas où l'index est out-of-bounds
        if currentTrackIndex >= tracks.count {
            currentTrackIndex = 0
        }

        let track = tracks[currentTrackIndex]
        print("▶️ Lecture : \(track.title)")
        audioPlayer.playPreview(from: track.preview)

        // Utilise track.id (qui est un UUID sous forme de String)
        markTrackAsPlayed(trackId: String(track.id))  // track.id est maintenant un String UUID
        isPlaying = true

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }

            print("✅ Fin de : \(track.title)")

            // Supprimer le morceau actuel
            self.tracks.remove(at: self.currentTrackIndex)

            // Si encore des morceaux, on lit le suivant
            if !self.tracks.isEmpty {
                // Pas besoin d’incrémenter l’index car on a retiré l’élément actuel
                self.playNextTrack()
            } else {
                print("🏁 Fin de la playlist")
                self.isPlaying = false
            }
        }
    }
}
