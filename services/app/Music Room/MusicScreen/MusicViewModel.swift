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
            print("❌ Aucun utilisateur trouvé dans UserDefaults")
            return
        }

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

                    switch httpResponse.statusCode {
                        case 200:
                            do {
                                let decodedResponse = try JSONDecoder().decode([Track].self, from: data)
                                self.tracks = decodedResponse
                            } catch {
                                self.errorMessage = "Erreur lors du décodage de la réponse"
                                print("❌ Erreur JSON:", error.localizedDescription)
                            }
                        case 400:
                            self.errorMessage = "Paramètre de recherche manquant"
                        case 401:
                            self.errorMessage = "Non autorisé, vérifiez votre token"
                        default:
                            self.errorMessage = "Erreur inconnue (\(httpResponse.statusCode))"
                    }
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

                switch httpResponse.statusCode {
                    case 201:
                        print("✅ Chanson ajoutée avec succès à la playlist !")
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

                print("✅ Statut HTTP: \(httpResponse.statusCode)")
                print("📥 Réponse JSON brute: \(String(data: data, encoding: .utf8) ?? "Aucune donnée")")

                if httpResponse.statusCode == 200 {
                    do {
                        let playlistTracks = try JSONDecoder().decode([PlaylistTrack].self, from: data)
                        self.tracks = [] // Vide la liste actuelle
                        self.tracks = playlistTracks.map {
                            Track(id: Int($0.trackId) ?? 0, title: $0.trackTitle, link: "", duration: 0, rank: 0, preview: $0.trackPreview, album: Album(id: 0, title: "", cover: $0.albumCover, coverSmall: $0.albumCover, coverMedium: $0.albumCover, coverBig: $0.albumCover, coverXL: $0.albumCover, tracklist: ""), artist: Artist(id: 0, name: "", link: "", picture: "", pictureSmall: "", pictureMedium: "", pictureBig: "", pictureXL: ""))
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

}
