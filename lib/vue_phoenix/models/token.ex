defmodule VuePhoenix.Token do
  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.{Token, User}

  schema "tokens" do
    belongs_to :user, User
    field :revoked, :boolean, default: false
    field :revoked_at, :utc_datetime
    field :code, :string

    timestamps()
  end

  def changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> unique_constraint(:code)
  end
end
