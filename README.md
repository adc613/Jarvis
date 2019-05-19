Project jarvis


# Running Postgres

```
docker run --rm --name pg[jdocker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v ~/tmp/docker/volumes/postgres:/var/lib/postgresql/data postgres
```
