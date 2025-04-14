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
    let preview: String?
    let album: Album
    let artist: Artist
    var uuid: String?

    enum CodingKeys: String, CodingKey {
        case id, title, link, duration, rank, preview, album, artist, uuid
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

                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print(" Réponse brute de l'API : \(responseString)")
                        }
                    }

                    switch httpResponse.statusCode {
                    case 201:
                        print("✅ Chanson ajoutée avec succès à la playlist !")

                        if let data = data {
                            do {
                                print(" Tentative de décodage des données JSON")
                                let decodedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                                print(" Réponse décodée : \(decodedResponse)")

                                if let responseDict = decodedResponse as? [String: Any],
                                   let deezerIdAny = responseDict["trackId"],
                                   let uuidAny = responseDict["id"] {

                                    let deezerId = String(describing: deezerIdAny)
                                    let uuid = String(describing: uuidAny)

                                    // Crée directement un objet Track avec l'UUID
                                    let newTrack = Track(
                                        id: Int(deezerId) ?? 0,
                                        title: "", // Remplir avec d'autres données selon besoin
                                        link: "",
                                        duration: 0,
                                        rank: 0,
                                        preview: "",
                                        album: Album(id: 0, title: "", cover: "", coverSmall: "", coverMedium: "", coverBig: "", coverXL: "", tracklist: ""),
                                        artist: Artist(id: 0, name: "", link: "", picture: "", pictureSmall: "", pictureMedium: "", pictureBig: "", pictureXL: ""),
                                        uuid: uuid
                                    )
                                    self.tracks.append(newTrack)
                                    print("✅ Nouveau morceau ajouté : \(newTrack.title) avec UUID : \(uuid)")
                                } else {
                                    print("❌ UUID non trouvé dans la réponse (clé manquante ou cast échoué)")
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
                                    artist: Artist(id: 0, name: "", link: "", picture: "", pictureSmall: "", pictureMedium: "", pictureBig: "", pictureXL: ""),
                                    uuid: $0.id
                                )
                            }

                            self.playlistTracks = Set(playlistTracks.map { $0.trackId })
                            self.currentTrackIndex = 0
                            
                            for track in playlistTracks {
                                self.associatedUUIDs[track.trackId] = track.trackId
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

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Erreur vote: \(error.localizedDescription)")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 201:
                            self.fetchAndPlayMostVotedTrack(playlistId: playlistId)
                            print("✅ Vote enregistré pour \(track.title)")
                        case 400:
                            print("❌ Mauvaise requête : déjà voté ou données invalides")
                        case 401:
                            print("❌ Non autorisé")
                        default:
                            print("❌ Erreur serveur: \(httpResponse.statusCode)")
                        }
                    }

                    if let data = data,
                       let responseString = String(data: data, encoding: .utf8) {
                        print("Réponse : \(responseString)")
                    }
                }
            }.resume()
        }
    
    func fetchAndPlayMostVotedTrack(playlistId: String) {
        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/votes") else {
            print("❌ URL invalide pour récupérer les votes")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let user = User.load() {
            request.setValue(user.token, forHTTPHeaderField: "token")
        } else {
            print("❌ Utilisateur non authentifié")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur lors de la récupération des votes: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    print("❌ Réponse invalide lors de la récupération des votes")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                        self.playMostVotedTrack(votes: json)
                    } else {
                        print("❌ Données de vote invalides")
                    }
                } catch {
                    print("❌ Erreur lors du décodage des données de vote: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    func playMostVotedTrack(votes: [String: Int]) {
        guard let mostVotedTrackId = votes.max(by: { $0.value < $1.value })?.key else {
            print("❌ Aucune piste avec des votes trouvée")
            return
        }

        if let track = self.tracks.first(where: { $0.uuid == mostVotedTrackId }) {
            if let previewURL = track.preview { // Vérifier si la preview est disponible
                self.audioPlayer.playPreview(from: previewURL)
                print("▶️ Lecture de la piste la plus votée : \(track.title)")
            } else {
                print("❌ Aucune URL de preview disponible pour la piste la plus votée")
            }
        } else {
            print("❌ Piste la plus votée non trouvée dans la liste des pistes")
        }
    }
}
