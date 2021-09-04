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
