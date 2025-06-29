# Friends

#### Create Friend Request

* Endpoint: `POST /friends/invitation` [PROTECTED]
* Data a envoyer:
    * invitedUserId -> l'id de l'utilisateur a invite
* Reponse
    * 500 -> Erreur serveur
    * 400 -> utilisateur inexistant ou invitedUserId non envoyee
    * 201 -> OK

```bash
curl -X POST "localhost:5001/friends/invitation" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d invitedUserId="14c228b0-c69e-4d8d-8589-f10a13ed3434"
```

#### List all friend request received [PROTECTED]

* Endpoint: `POST /friends/invitation`
* Reponse:
    * 500: Erreur serveur
    * 200: OK

```bash
curl "localhost:5001/friends/invitation" -H token:4890af5d-5031-405e-ac5c-5c29c89a9746
```

#### Accept friend request [PROTECTED]

* Endpoint: `POST /friends/invitation/accept`
* Reponse:
    * 500: Erreur serveur
    * 400: Request id not found
    * 200: OK

```bash
curl -X POST "localhost:5001/friends/invitation/accept" -H token:4890af5d-5031-405e-ac5c-5c29c89a9746 -d request_id=xxx
```

#### Decline friend request [PROTECTED]

* Endpoint: `POST /friends/invitation/decline`
* Reponse:
    * 500: Erreur serveur
    * 400: Request id not found
    * 200: OK

```bash
curl -X POST "localhost:5001/friends/invitation/accept" -H token:4890af5d-5031-405e-ac5c-5c29c89a9746 -d request_id=xxx
```

#### List all friends of users [PROTECTED]

* Endpoint: `GET /friends`
* Reponse:
    * 500: Erreur serveur
    * 200: List of friends

```bash
curl "localhost:5001/friends" -H token:4890af5d-5031-405e-ac5c-5c29c89a9746
```
