#### How to start the project for production ?

Juste run

```
./scripts/up.sh
```

#### How to start the project for developement ?

First run the database

```
docker-compose up --build -d database
```

Then install the necessary package for the api

```
npm i
```

#### How to access local postgres ?

If you have pg cli installed


```
./scripts/enter-in-local-postgres.sh
```

If you have psql installed

```
./scripts/pg_enter-in-local-postgres.sh
```

#### How to install a new package ?

For example in the api

```
npm i --workspace=@music-room/api package-name
```

#### How to run the api ?

From the root of the project

```
npm run start:api
```
