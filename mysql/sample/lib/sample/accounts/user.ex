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
