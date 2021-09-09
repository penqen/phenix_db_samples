# Elixir + Phoenix Live without Database

データベースを使用しない`Phoenix Live`サンプルです。

## サンプルの実行

以下のコマンドを実行して、`http://localhost:4000/`へ移動する。

```bash
cd live
docker compose run --rm web setup
docker compose up
```

## `Phoenix Live`サンプルプロジェクト作成

`live`ディレクトリ下に新しい`Phoenix Live`プロジェクトを作成することを想定しています。
まず、`mix phx.new`コマンドを実行するためのコンテナをビルドします。

```bash
# build container to execute `mix phx.new` command
docker build --target phx.new --tag mix:latest docker/phx
# mix help phx.new が実行される
docker run --rm -it mix
```

以下のコマンドを実行し、`live`ディレクトリ下に`sample`プロジェクトを作成します。

```bash
# create `live` directory
mkdir live
# create phoenix project in `live` directory
docker run --rm -v $PWD/live:/app -w /app \
  -it mix phx.new sample --module Sample \
  --no-install --no-dashboard --no-ecto --live
```

`live`ディレクトリに`docker-compose.yml`を作ります。

```yml
version: "3.9"

services:
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

volumes:
  web_build:
  web_deps:
  web_node_modules:

```

```bash
# mix setupを実行する。
docker compose run --rm web setup
# コンテナを起動する。
docker compose up
# or
docker compose up -d
```

### `Live`の変更

`lib/sample_web/live/page_live.ex`を編集します。

```elixir
defmodule SampleWeb.PageLive do
  use SampleWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        query: "",
        results: %{},
        users: [%{name: "foo", email: "foo@example.com"}],
        name: "",
        email: ""
      )
    }
  end

  @imp true
  def handle_event("register", %{"name" => name, "email" => email}, socket) do
    users = socket.assigns.users

    with name when not is_tuple(name) <- validate_name(name),
         email when not is_tuple(email) <- validate_email(email) do
      {
        :noreply,
        assign(
          socket,
          name: "",
          email: "",
          users: [%{name: name, email: email} | users]
        )
      }
    else
      {:error, message} ->
        {
          :noreply,
          socket
          |> put_flash(:error, message)
          |> assign(
            name: name,
            email: email,
            users: users
          )
        }
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

### `Template`の変更

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
