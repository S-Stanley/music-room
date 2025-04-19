# Setup

#### Environement variables

You will need to create a `.env` file in `services/api/` with this value:

```
DATABASE_URL=postgresql://postgres:not_so_secret@localhost:5431/dev
RESEND_API_KEY=< API KEY >
```

#### Fixtures

To generate fixtures, juste run

```sh
./scripts/reset-local-database.sh
```
