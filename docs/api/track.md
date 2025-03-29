# Track

#### Search for a track

* Endpoint: GET `/track/search` [PROTECTED]
* Query params a envoyer:
    * q
* Reponse
    * 200 -> Liste de musique retournee
    * 400 -> La valeur `q` en query params n'a pas ete envoye.
    * 500 -> Erreur serveur

Example de requete:

```bash
curl localhost:5001/track/search?q=rihanna -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b | jq
```

#### Get all tracks of playlist

* Endpoint: GET `/track/:playlist_id/` [PROTECTED]
* Response
  * 200 -> Return all tracks of playlist
  * 400 -> Playlist do not exist
  * 500 -> Erreur serveur


```bash
curl "localhost:5001/track/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```
