# Users

#### Se connecter avec un email

* Endpoint: `/users/email/signin`
* Data a envoyer:
    * email
    * password
* Reponse
    * 200 -> Identifiant corrects
    * 400 -> L'email n'existe pas, ou l'email ou le password n'a pas ete recu par le serveur

Example de requete:

```bash
curl localhost:5001/users/email/signin/ -X POST  -d email=user@music.room
```

#### S'inscrire avec un email

* Endpoint: `/users/email/signiup`
* Data a envoyer:
    * email
    * password
* Reponse
    * 201 -> L'utilisateur est cree
    * 400 -> L'email et/ou le password n'existe pas, ou n'a pas ete recu par le serveur

Example de requete:

```bash
curl localhost:5001/users/email/signup/ -X POST  -d email=user_to_create@music.room -d password=123
```
