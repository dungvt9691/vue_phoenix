defmodule VuePhoenix.Identify.Token do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.{Token, User}

  schema "tokens" do
    belongs_to :user, User
    field :external_id, Ecto.UUID, autogenerate: true
    field :revoked, :boolean, default: false
    field :revoked_at, :naive_datetime
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
