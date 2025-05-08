# Playlists

#### Create playlist

* Endpoint: POST `/playlist` [PROTECTED]
* Data a envoyer:
    * name
    * type: "PUBLIC" ou "PRIVATE"
    * password: only for private playlist
    * orderType: "VOTE" ou "POSITION"
* Reponse
    * 201 -> Playlist cree
    * 400 -> 
        * Name ou type n'as pas ete envoye
        * Type n'as pas le bon format
        * OrderType est vide ou avec la mauvaise valeur
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
  * 400 ->
    * TrackId is not sent
    * Playlist does not exist
    * TrackId does not exist
    * Maximum number of unplayed track reached (50)

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
    * 200 -> User joined playlist or already joined
    * 400 ->
        * Playlist does not exist
        * Passwod is wrong for private playlist
    * 500 -> Server error
* Exemple:

Example do not work on default data du to password encryption missing, you gave to create the playlist first with a password and replace playlist_id and password.

```bash
curl -X POST "localhost:5001/playlist/2a8fd55d-b9f9-4ec9-9398-32a22d97e64c/join" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d password=123
```

#### Vote for next track [PROTECTED]

* Endpint: POST `/playlist/:playlist_id/vote/:track_id
* Response:
    * 200 -> User voted for track
    * 400:
        * Playlist, user track not found
        * User already vote for this track in the playlist
    * 500 -> Server error

```bash
curl -X POST "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/vote/48f0a90f-74d4-4eae-9f38-e1940bc62a4b" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```

#### List all members of playlist [PROTECTED]

* Endpoint: GET `/playlist/:playlist_id/members`
* Reponse
    * 200 -> All members of playlist
    * 400 -> Unknow playlist
    * 500 -> Erreur serveur

```bash
curl -X GET "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/members" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```

#### Edit track position [PROTECTED]

* Endpoint: `POST /playlist/:playlist_id/edit`
* Data a envoyer:
    * track_id
    * trackIdAfter
* Reponse:
    * 200 -> OK, updated
    * 400 ->
        * Playlist not found
        * Track or trackAfter not found
        * User is not member of private playlist
    * 500 -> Erreur serveur

```bash
curl -X POST "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/edit" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d trackIdAfter=f77b7dce-74ed-4312-944f-340eb1d3f602 -d trackId=afd1b795-2ad2-44af-b9a6-c3910f3fe6ec
```

#### Edit session playlist [PROTECTED]
* Endpoint: `POST /playlist/:playlist_id/edit/session`
* Data a envoyer:
    * start: Datetime member of playlist can vote
    * end: Datetime member of playlist can vote
    * addr: Address near people can vote
* Reponse:
    * 200: OK
    * 400:
        * Playlist not found
        * Format of datetime is wrong
        * Address localisation cannot be found
    * 500: Erreur serveur

```bash
curl -X POST "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/edit/session" \
-H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b \
-d start=2025 \
-d end=2025 \
-d addr="Paris"
```
