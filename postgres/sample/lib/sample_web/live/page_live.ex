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
