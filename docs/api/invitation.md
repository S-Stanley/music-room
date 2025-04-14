# Invitation

#### Create Invitation

* Endpoint: `POST /playlist/:playlist_id/invitation` [PROTECTED]
* Data a envoyer:
    * userId -> l'utilisateur a inviter
* Reponse
    * 201 -> Invitation cree
    * 400 -> Playlist id ou user id non recu ou non valable
    * 500 -> Erreur serveur

Example de requete:

```bash
curl -X POST "localhost:5001/playlist/e41fa7e7-05a7-4812-9a8b-446ecbc78b2e/invitations" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d userId=14c228b0-c69e-4d8d-8589-f10a13ed3434
```

#### Get all invitations where user is invited [PROTECTED]

* Endpoint: `GET /users/invitations`
* Reponse:
    * 200 -> :iste des invitations
    * 500 -> Erreur serveur

```bash
curl "localhost:5001/users/invitations" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```
