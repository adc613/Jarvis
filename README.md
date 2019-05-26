Project jarvis


# Running Postgres

Workstation
```
docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v ~/tmp/docker/volumes/postgres:/var/lib/postgresql/data postgres
```

RPi
```
docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v ~/tmp/docker/volumes/postgres:/var/lib/postgresql/data tobi312/rpi-postgresql
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

# Random notes

## RPi docker container

* Had to compile the RPi go file for arm archeticture. Without that the container
  wouldn't run in the go environ
  ```
  GOOS=linux GOARCH=arm GOARM=6 go build -o main main.go
  ```

## Phoenix on RPi

* Had to delete the mix.lock and reinstall deps for everything to work on the
  RPi
* Learned about [asdf](https://github.com/asdf-vm/asdf) and decided to use it on
  the RPi and my workstation to manage elixir and erlang environments

## Hue

You need a username to make calls to the hue locally. [doc](https://developers.meethue.com/develop/get-started-2/)
