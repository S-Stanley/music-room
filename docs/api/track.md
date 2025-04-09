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

#### Set track as already played

* Endpoint: PATCH `/track/:track_id/played` [PROTECTED]
* Reponse:
    * 200 -> Updated
    * 400 -> Track not found
    * 500 -> Serveur erreur


```bash
curl -X PATCH "localhost:5001/track/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/played" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```
