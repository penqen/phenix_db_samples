# Elixir + Phoenix + Database Samples

これらのサンプルは、`Phoenix`と`Database`の組み合わせの例です。
全てのサンプルは、`Docker Compose`を用いて実行することを想定しています。
サンプルは、時間がある時に追加する予定です。

## Samples

各サンプルは、ディレクトリ名に対応して作成します。
例えば、`MySQL`であれば`mysql`以下のようなディレクトリ構成になります。

```bash
.
├── mysql                   # Phoenix Live + MySQL Sample
│   ├── samples             # Phoenix Project
│   ├── docker-compose.yml
```

各サンプルの内容は、ユーザ情報(名前とEmail)を登録して一覧する単純なものです。
作成したあるいは作成したいサンプルは以下の通りです。

- [x] [only Phoenix (no_ecto)](./no_ecto.jp.md)
- [x] [only Phoenix Live (live)](./live.jp.md)
- [x] [PostgreSQL (postgres)](./postgres.jp.md)
- [x] [MySQL (mysql)](./mysql.jp.md)
- [ ] MariaDB (mariadb)
- [ ] MongoDB (mongodb)
- [ ] Mnesia (mnesia)

## Execution of Sample

`xxx`ディレクトリにあるサンプルを実行する例です。
以下のコマンドを実行した後に、`http://localhost:4000`を開きます。

```sh
cd xxx
docker compose run --rm web setup
docker compose up
```

## Clean Up

作成された`Volume`などを削除します。

```sh
docker compose down
# 必要があれば
docker volume prune && docker network prune && docker image prune
# イメージを確認してから削除してください。
docker rmi xxx_web
```
