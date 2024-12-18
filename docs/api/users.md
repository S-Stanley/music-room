# Users

#### Se connecter avec un email

* Endpoint: `/users/email/signin`
* Data a envoyer:
    * Email
* Reponse
    * 200 -> Identifiant corrects
    * 400 -> L'email n'existe pas, ou n'a pas ete recu par le serveur

Example de requete:

```bash
curl localhost:5001/users/email/signin/ -X POST  -d email=user@music.room
```
