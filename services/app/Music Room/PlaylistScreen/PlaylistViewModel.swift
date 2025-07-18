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
    @Published var locationManager = LocationManager()

    
    init(playlistId: String) {
            self.playlistId = playlistId
        }
    
    func fetchTracksForPlaylist(playlistId: String, triggerPlayback: Bool = true, completion: @escaping (Bool, String?) -> Void) {
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
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("📥 Réponse JSON brute: \(jsonString)")
                            } else {
                                print("❌ Impossible de convertir les données en chaîne de caractères")
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
                                uuid: $0.id, // L'UUID semble être dans le champ 'id' de PlaylistTrack
                                voteCount: $0.votes,
                                addedBy: $0.user?.name
                            )
                        }

                        // Reconstruire associatedUUIDs en maintenant l'ordre de 'tracks'
                        self.associatedUUIDs = [:]
                        for track in self.tracks {
                            self.associatedUUIDs[String(track.id)] = track.uuid // Utilise track.id (Int converti en String) comme clé et track.uuid comme valeur
                            print("Track \(track.id) voteCount: \(track.voteCount ?? 0), UUID: \(track.uuid ?? "nil")")
                        }

                        self.playlistTracks = Set(playlistTracks.map { $0.trackId })

//                        print("Contenu de associatedUUIDs après fetchTracksForPlaylist : \(self.associatedUUIDs)")

                        completion(true, nil)
                        if triggerPlayback {
                            self.startAutomaticPlaybackIfNeeded()
                        }
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

        guard let user = User.load() else {
            print("❌ Utilisateur non authentifié")
            return
        }

        guard let ipURL = URL(string: "https://api.ipify.org?format=json") else {
            print("❌ URL IP invalide")
            return
        }

        URLSession.shared.dataTask(with: ipURL) { data, _, error in
            if let error = error {
                print("❌ Erreur récupération IP : \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let userIP = json["ip"] else {
                print("❌ Impossible de lire l'IP")
                return
            }

            print("🌐 IP publique utilisateur : \(userIP)")

            guard let voteURL = URL(string: "http://localhost:5001/playlist/\(playlistId)/vote/\(uuid)") else {
                print("❌ URL de vote invalide")
                return
            }

            var request = URLRequest(url: voteURL)
            request.httpMethod = "POST"
            request.setValue(user.token, forHTTPHeaderField: "token")
            let bodyString = "ip_addr=\(userIP)"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyString.data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Erreur vote: \(error.localizedDescription)")
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200:
                            print("✅ Vote enregistré pour \(track.title)")
                            self.fetchTracksForPlaylist(playlistId: playlistId) { success, error in
                                if success {
                                    print("🔁 Pistes mises à jour après le vote")
                                } else {
                                    print("❌ Erreur MAJ pistes : \(error ?? "Inconnue")")
                                }
                            }
                        case 400:
                            print("❌ Mauvaise requête : IP manquante ou invalide")
                        case 500:
                            print("Error: non geré")
                        default:
                            print("❌ Erreur serveur : \(httpResponse.statusCode)")
                        }
                    }

                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📩 Réponse : \(responseString)")
                    }
                }
            }.resume()

        }.resume()
    }

    func moveTrackInPlaylist(from source: IndexSet, to destination: Int, playlistId: String) {
        print("🔴 Début de moveTrackInPlaylist. Source: \(source), Destination: \(destination)")
        guard let fromIndex = source.first else {
            print("🔴 Erreur: Index source invalide.")
            return
        }
        print("🔴 fromIndex: \(fromIndex)")
        print("🔴 tracks avant déplacement local: \(tracks.map { $0.id })")

        let movedTrack = tracks[fromIndex]
        print("🔴 Morceau déplacé (avant déplacement local): \(movedTrack.id)")

        // Créer une copie temporaire de l'array tracks
        var tempTracks = tracks
        print("🔴 tempTracks initial: \(tempTracks.map { $0.id })")

        // Supprimer l'élément à l'index source
        tempTracks.remove(at: fromIndex)
        print("🔴 tempTracks après suppression: \(tempTracks.map { $0.id })")

        // Insérer l'élément à la nouvelle destination
        let adjustedDestination = destination > fromIndex ? destination - 1 : destination
        if adjustedDestination <= tempTracks.count {
            tempTracks.insert(movedTrack, at: adjustedDestination)
        } else {
            tempTracks.append(movedTrack) // Gérer le cas où la destination est à la fin
        }
        print("🔴 tempTracks après insertion à la destination \(destination) (ajustée: \(adjustedDestination)): \(tempTracks.map { $0.id })")

        // Trouver le UUID du morceau déplacé
        guard let trackUUID = associatedUUIDs[String(movedTrack.id)] else {
            print("🔴 Erreur: UUID introuvable pour le track_id \(movedTrack.id) dans associatedUUIDs: \(associatedUUIDs)")
            return
        }
        print("🔴 UUID du morceau déplacé: \(trackUUID)")

        // Trouver le track après la future position DANS LA COPIE TEMPORAIRE
        let trackIdAfterUUID: String? = {
            let insertIndexForAfter = adjustedDestination + 1
            guard insertIndexForAfter < tempTracks.count else {
                print("🔴 insertIndexForAfter (\(insertIndexForAfter)) hors des limites de tempTracks (\(tempTracks.count)). Pas de track après.")
                return nil
            }
            let afterTrack = tempTracks[insertIndexForAfter]
            let uuidAfter = associatedUUIDs[String(afterTrack.id)]
            print("🔴 Morceau après (dans tempTracks) à l'index \(insertIndexForAfter): \(afterTrack.id), UUID: \(uuidAfter ?? "nil")")
            return uuidAfter
        }()
        print("🔴 trackIdAfterUUID déterminé: \(trackIdAfterUUID ?? "nil")")

        print("ℹ️ trackIdAfterUUID au moment du déplacement : \(trackIdAfterUUID ?? "nil")")

        // Construire l'URL de la requête
        guard let url = URL(string: "http://localhost:5001/playlist/\(playlistId)/edit") else {
            print("🔴 Erreur: URL invalide.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        guard let user = User.load() else {
            print("🔴 Erreur: Aucun utilisateur connecté.")
            return
        }
        request.setValue(user.token, forHTTPHeaderField: "token")

        var body = "trackId=\(trackUUID)" // CHANGEMENT ICI: track_id devient trackId
        if let afterUUID = trackIdAfterUUID, !afterUUID.isEmpty {
            body += "&trackIdAfter=\(afterUUID)"
        }
        print("🔴 Corps de la requête envoyé: \(body)")

        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔴 Erreur réseau : \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("🔴 Erreur : Réponse invalide du serveur.")
                    return
                }
                if httpResponse.statusCode == 200 {
                    print("✅ Ordre mis à jour côté serveur")
                    // ⚠️ IMPORTANT : Tu devras probablement mettre à jour ton array 'tracks' ici
                    // pour refléter le nouvel ordre après un succès du serveur.
                } else {
                    print("🔴 Erreur serveur (\(httpResponse.statusCode))")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("🔴 Réponse serveur : \(responseString)")
                    }
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
            self.fetchTracksForPlaylist(playlistId: self.playlistId, triggerPlayback: false) { success, error in
                if success {
                    if self.tracks.isEmpty {
                        print("🏁 Fin de la playlist")
                        self.audioPlayer.stop()
                        self.isPlaying = false
                        self.hasStartedPlaying = false
                    } else {
                        self.playFirstTrack()
                    }
                }
                else {
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
    
    func stopPlayback() {
        print("🛑 Arrêt de la lecture")
        audioPlayer.stop()
        isPlaying = false
        hasStartedPlaying = false
    }

}

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last?.coordinate
    }
}

