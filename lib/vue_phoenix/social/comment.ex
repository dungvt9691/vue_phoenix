defmodule VuePhoenix.Social.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.User
  alias VuePhoenix.Social.Post

  schema "comments" do
    belongs_to :user, User
    belongs_to :post, Post
    field :content, :string
    field :external_id, Ecto.UUID, autogenerate: true

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_id])
    |> validate_required([:content])
  end

  def changeset_for_update(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
