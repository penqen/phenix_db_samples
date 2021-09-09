# Elixir + Phoenix without Database and Node.js

データベースとNode.jsを使わない最小単位のサンプルです。

## サンプルの実行

以下のコマンドを実行して、`http://localhost:4000/`へ移動する。

```bash
cd no_ecto
docker compose run --rm web setup
docker compose up
```

## `Phoenix`サンプルプロジェクト作成

`no_ecto`ディレクトリ下に新しい`Phoenix`プロジェクトを作成することを想定しています。
まず、`mix phx.new`コマンドを実行するためのコンテナをビルドします。

```bash
# build container to execute `mix phx.new` command
docker build --target phx.new --tag mix:latest docker/phx
# mix help phx.new が実行される
docker run --rm -it mix
```

以下のコマンドを実行し、`no_ecto`ディレクトリ下に`sample`プロジェクトを作成します。

```bash
# create `no_ecto` directory
mkdir no_ecto
# create phoenix project in `no_ecto` directory
docker run --rm -v $PWD/no_ecto:/app -w /app \
  -it mix phx.new sample --module Sample \
  --no-install --no-webpack --no-dashboard --no-ecto
```

`no_ecto`ディレクトリに`docker-compose.yml`を作ります。

```yml
version: "3.9"

services:
  web:
    build:
      context: .
      dockerfile: ../docker/phx/Dockerfile
      target: development
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
    ports: 
      - 4000:4000
    tty: true
    stdin_open: true

volumes:
  web_build:
  web_deps:

```

`dev.server`コンテナをビルドし、起動します。

```bash
# 初期化を行う
docker compose run --rm web setup
# コンテナを起動する
docker compose up
# or
docker compose up -d
```

### Routerの変更

ユーザ登録用のルートを追加する。

```elixir
defmodule SampleWeb.Router do
  use SampleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    # 追加
    post "/", PageController, :new
  end
end

```

### Controllerの変更

ユーザデータの初期値を`@users`に設定し、ユーザ情報はセッションで管理する。

```elixir
defmodule SampleWeb.PageController do
  use SampleWeb, :controller

  @users [
    %{name: "foo", email: "foo@example.com"}
  ]

  def index(conn, _params) do
    conn
    |> put_session("users", @users)
    |> assign(:users, @users)
    |> assign(:name, "")
    |> assign(:email, "")
    |> render("index.html")
  end

  def new(conn, %{"user" => %{"name" => name, "email" => email}}) do
    users = get_session(conn, "users")

    with name when not is_tuple(name) <- validate_name(name),
         email when not is_tuple(email) <- validate_email(email) do
      conn
      |> put_session("users", [%{name: name, email: email} | users])
      |> assign(:users, [%{name: name, email: email} | users])
      |> assign(:name, "")
      |> assign(:email, "")
      |> render("index.html")
    else
      {:error, message} ->
        conn
        |> put_session("users", users)
        |> put_flash(:error, message)
        |> assign(:users, users)
        |> assign(:name, name)
        |> assign(:email, email)
        |> render("index.html")
    end
  end

  defp validate_name(""), do: {:error, "name is not blank"}
  defp validate_name(name), do: name

  defp validate_email(email) do
    ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
    |> Regex.run(email)
    |> case do
      nil -> {:error, "email is invalid format"}
      _ -> email
    end
  end
end

```

### View・Templateの変更

`csrf`対策として、`csrf_token`を`view`から発行できるようにするため、`lib/sample_web.ex`を編集する。

```elixir
defmodule SampleWeb do
  ...
  def view do
    quote do
      use Phoenix.View,
        root: "lib/sample_web/templates",
        namespace: SampleWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [
          get_csrf_token: 0, # 追加
          get_flash: 1,
          get_flash: 2,
          view_module: 1,
          view_template: 1
        ]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end
  ...
end

```

`lib/sample_web/templates/page/index.html.eex`を編集する。

```html (eex)
<section class="phx-hero">
  <h2>New User</h2>

  <%= form_for @conn, Routes.page_path(@conn, :new), [
    as: :user,
    csrf_token: get_csrf_token()
  ], fn f -> %>
    <%= text_input f, :name, value: @name, placeholder: "Name" %>
    <%= text_input f, :email, value: @email, placeholder: "Email" %>
    <%= submit "Register" %>
  <% end %>

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
