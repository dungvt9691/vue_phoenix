defmodule VuePhoenix.Authenticator.Token do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Authenticator.{Token, User}

  schema "tokens" do
    belongs_to :user, User
    field :revoked, :boolean, default: false
    field :revoked_at, :utc_datetime
    field :code, :string

    timestamps()
  end

  def changeset(%Token{} = token, attrs) do
    token
    |> cast(attrs, [:code, :user_id])
    |> validate_required([:code, :user_id])
    |> unique_constraint(:code)
  end
end
