defmodule VuePhoenix.Social.Image do
  @moduledoc false

  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.User
  alias VuePhoenix.Social.Post

  schema "images" do
    belongs_to :user, User
    belongs_to :post, Post
    field :attachment, VuePhoenix.Image.Type
    field :external_id, Ecto.UUID, autogenerate: true

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [])
  end

  @doc false
  def changeset_for_update(image, attrs) do
    image
    |> cast(attrs, [:post_id])
    |> cast_attachments(attrs, [:attachment])
  end
end
