# Playlists

#### Create playlist

* Endpoint: POST `/playlist` [PROTECTED]
* Data a envoyer:
    * name
    * type: "PUBLIC" ou "PRIVATE"
    * password: only for private playlist
* Reponse
    * 201 -> Playlist cree
    * 400 -> Name ou type n'as pas ete envoye, type n'as pas le bon format
    * 500 -> Erreur serveur

Example de requete:

```bash
curl -X POST "localhost:5001/playlist/" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d name=playlist -d type=PUBLIC
```

#### List all playlists

* Endpoint: GET `/playlist` [PROTECTED]
* URL params
    * skip: default is 0
    * take: max and default are 50
* Reponse
    * 200 -> Return all playlists
    * 400 -> skip or take query params are not parseable to Int
    * 500 -> Erreur serveur

Example de requete:

```bash
curl "localhost:5001/playlist/?take=10&skip=0" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```

#### Add song to playlist

* Endpoint: POST `/playlist/:playlist_id` [PROTECTED]
* Body params
  * trackId -> deezert trackId
* reponse
  * 201 -> Song is added to playlist
  * 400 -> TrackId is not sent, playlist does not exist or trackId does not exist

  ```bash
curl "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d trackId=98087618
  ```

#### Get all tracks of playlist

* Endpoint: GET `/playlist/:playlist_id/track` [PROTECTED]
* Response
  * 200 -> Return all tracks of playlist
  * 400 -> Playlist do not exist
  * 500 -> Erreur serveur


```bash
curl "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/track" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```
#### Join playlist [PROTECTED]

* Endpoint: POST `/playlist/:playlist_id/join`
* Response
    * 200 -> User joigned playlist
    * 400 -> Playlist does not exist or passwod is wrong for private playlist
    * 500 -> Server error
* Exemple:

Example do not work on default data du to password encryption missing, you gave to create the playlist first with a password and replace playlist_id and password.

```bash
curl "localhost:5001/playlist/2a8fd55d-b9f9-4ec9-9398-32a22d97e64c/join" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d password=123
```
