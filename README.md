# Elixir + Phoenix + Database Samples

Thease samples are examples of the combination of `Phoenix` and `Database`.
They are assumed to be run using `Docker Compose`.
Samples will be added if have time.

Japanese document is [here](docs/README.jp.md).

## Samples

Each sample, corresponding to the directory name, are created.
For example, directory name of a sample with `MySQL` is `mysql` and directory structure of its is followings:

```bash
.
├── mysql                   # Phoenix Live + MySQL Sample
│   ├── samples             # Phoenix Project
│   ├── docker-compose.yml
```

The contents of each sample are common.
Register user information (name and e-mail) and display the list.
Documents for each sample are not writing now.

- [x] only Phoenix (no_ecto)
- [x] only Phoenix Live (live)
- [x] PostgreSQL (postgres)
- [x] MySQL (mysql)
- [ ] MariaDB (mariadb)
- [ ] MongoDB (mongodb)
- [ ] Mnesia (mnesia)

## Execution of Sample

Here is an example of running a sample is in `xxx` directory.
Run the following command to open `http://localhost:4000`.

```sh
cd xxx
docker compose run --rm web setup
docker compose up
```

## Clean Up

Delete created `Volume`, `Network`, etc.

```sh
docker compose down
docker volume prune && docker network prune && docker image prune
docker rmi xxx_web
```
