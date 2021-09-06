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
