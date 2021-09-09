# Elixir + Phoenix Live with Postgres

`Postgres`と`Phoenix Live`のサンプルです。

## サンプルの実行

以下のコマンドを実行して、`http://localhost:4000`へ移動する。

```bash
cd postgres
docker compose run --rm web setup
docker compose up
```

## `Phoenix Live`サンプルプロジェクト作成

`postgres`ディレクトリ下に新しい`Phoenix Live`プロジェクトを作成することを想定しています。
まず、`mix phx.new`コマンドを実行するためのコンテナをビルドします。

```bash
# build container to execute `mix phx.new` command
docker build --target phx.new --tag mix:latest docker/phx
# mix help phx.new が実行される
docker run --rm -it mix
```

以下のコマンドを実行し、`postgres`ディレクトリ下に`sample`プロジェクトを作成します。

```bash
# create `posgres` directory
mkdir postgres
# create phoenix project in `postgres` directory
docker run --rm -v $PWD/postgres:/app -w /app \
  -it mix phx.new sample --module Sample \
  --no-install --no-dashboard \
  --live --database postgres
```

`postgres`ディレクトリに`docker-compose.yml`を作ります。

```yml
version: "3.9"

services:
  db:
    image: postgres:13.4-alpine
    container_name: db
    #restart: always
    environment:
      - POSTGRES_USER=phoenix
      - POSTGRES_PASSWORD=password
      - POSTGRES_HOST=db
      - POSTGRES_INITDB_ARGS="--encoding=UTF-8"
      - TZ="Asia/Tokyo"
    ports:
      - 5432:5432
    volumes:
      - postgres:/var/lib/postgresql/data

  web:
    build:
      context: .
      dockerfile: ../docker/phx/Dockerfile
      target: development.node
      args: 
        # define working and app_root directories on building phase
        - WORKING=/app
        - APP_ROOT=./sample
    environment: 
      - MIX_ENV=dev
    volumes:
      - ./sample:/app
      - web_build:/app/_build
      - web_deps:/app/deps
      - web_node_modules:/app/assets/node_modules
    ports: 
      - 4000:4000
    tty: true
    stdin_open: true
    depends_on: 
      - db

volumes:
  web_build:
  web_deps:
  web_node_modules:
  postgres:


```

`config/dev.exs`のデータベースの設定を変更する。

```elixir
...

# Configure your database
config :sample, Sample.Repo,
  username: "phoenix",
  password: "password",
  database: "sample_dev",
  hostname: "db",
  port: 5432,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

...
```

```bash
# mix setup を行う
docker compose run --rm web setup
# コンテナを起動する。
docker compose up
# or
docker compose up -d
```

### `User`モデルの作成

ユーザモデルを作成する。

```bash
# User schema を作成する
docker compose run --rm web phx.gen.context \
  Accounts User users name:string email:string
# リポジトリを更新する 
docker compose run --rm web ecto.migrate
```

`lib/sample/accounts/user.ex`を編集します。

```elixir
defmodule Sample.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @email_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  schema "users" do
    field(:email, :string)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, @email_regex, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
  end
end

```


### `Live`の変更

`lib/sample_web/live/page_live.ex`を編集します。

```elixir
defmodule SampleWeb.PageLive do
  use SampleWeb, :live_view

  alias Sample.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        users: Accounts.list_users(),
        name: "",
        email: ""
      )
    }
  end

  @imp true
  def handle_event("register", params, socket) do
    params
    |> Accounts.create_user()
    |> case do
      {:ok, user} ->
        {
          :noreply,
          assign(
            socket,
            users: Accounts.list_users(),
            name: "",
            email: ""
          )
        }

      {:error, changeset} ->
        [{key, {message, _}} | _] = changeset.errors

        {
          :noreply,
          socket
          |> put_flash(:error, "#{key} : #{message}")
          |> assign(
            users: Accounts.list_users(),
            name: params["name"],
            email: params["email"]
          )
        }
    end
  end
end

```

### `Temmplate`の変更

`lib/sample_web/live/page_live.html.leex`を編集します。

```html (leex)
<section class="phx-hero">
  <h2>New User</h2>
  <form phx-submit="register">
    <input
      type="text"
      name="name"
      value="<%= @name %>"
      placeholder="Name"
      autocomplete="off"
    />
    <input
      type="text"
      name="email"
      value="<%= @email %>"
      placeholder="Email"
      autocomplete="off"
    />
    <button type="submit" phx-disable-with="Searching...">Register</button>
  </form>
</section>

<section class="row">
  <article class="column">
    <h2>Users</h2>
    <table>
      <tr>
        <th>Name</th>
        <th>Email</th>
      </tr>

      <%= for user <- @users do %>
        <tr>
          <td><%= user.name %><td>
          <td><%= user.email %><td>
        <tr>
      <% end %>

    </table>
  </article>
</section>

```
