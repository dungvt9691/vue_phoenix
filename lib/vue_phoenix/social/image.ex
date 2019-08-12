defmodule VuePhoenix.Social.Image do
  @moduledoc false

  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.User
  alias VuePhoenix.Social.PostImage

  schema "images" do
    belongs_to :user, User
    has_many :post_images, PostImage
    has_many :posts, through: [:post_images, :post]
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
    |> cast(attrs, [])
    |> cast_attachments(attrs, [:attachment])
  end
end
