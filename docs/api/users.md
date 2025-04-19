# Users

### PROTECTED ENDPOINT

Should be call with `token` of user in headers

#### Se connecter avec un email

* Endpoint: POST `/users/email/signin`
* Data a envoyer:
    * email
    * password
* Reponse
    * 200 -> Identifiant corrects
    * 400 -> L'email n'existe pas, ou l'email ou le password n'a pas ete recu par le serveur

Example de requete:

```bash
curl localhost:5001/users/email/signin/ -X POST  -d email=user@music.room -d password=123
```

#### S'inscrire avec un email

* Endpoint: POST `/users/email/signup`
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

#### Avoir les infos d'un utilisateur [PROTECTED]

* Endpoint: `/users/:user_id`
* Header: token
* Reponse
    * 200 -> Les infos de l'utilisateur
    * 400 -> Le format de l'id n'est pas le bon ou l'user_id n'existe pas


```bash
curl localhost:5001/users/f6cb6e9e-7e19-485c-a4b2-fc10128e4b71 -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```

#### Modifier les info d'un utilisateur [PROTECTED]

* Endpoint: POST `/users/info`
* Header: token
* Reponse
  * 200 -> Utilisateur modifie


```bash
curl -X POST localhost:5001/users/info -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b -d email=test@email.com 
```


#### Get all users [PROTECTED]

* Endpoint: `/users/`
* Header: token
* Query params
    * take: combien d'utilisateurs a retourner
    * skip: combien d'utilisateur a skipper
* Reponse:
    * 200 -> Retourne tous les utilisateurs
    * 400 -> Take is greater than maximum (50)

```bash
curl "localhost:5001/users/?take=20&skip=0" -H token:c055fb5c-7d35-42a8-b4e7-a20a706d999b
```
