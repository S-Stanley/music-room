#!/bin/bash

source ./services/api/.env

psql -d $DATABASE_URL -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

npm run migrate:dev --workspace=@music-room/api

psql -d $DATABASE_URL -f ./fixtures/users.sql
psql -d $DATABASE_URL -f ./fixtures/playlists.sql

echo -e "\nLocal db on $DATABASE_URL is now clean and instancied with fixtures";
