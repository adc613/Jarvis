Project jarvis


# Running Postgres

```
docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v ~/tmp/docker/volumes/postgres:/var/lib/postgresql/data postgres
```

# Running dev server

## Pre-reqs

1) Install everything. I don't have instructors for that. You'll need elixir/pheonix
   and docker.
2) Run postgres database [see adove].
3) Run dev server command is below

```
mix phx.server
```

# Adding dependencies


Add dependencies to [mix.exs](console/mix.exs)

```
mix deps.get
```
