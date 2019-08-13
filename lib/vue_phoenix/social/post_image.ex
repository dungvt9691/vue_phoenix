defmodule VuePhoenix.Social.PostImage do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Social.{Image, Post}

  schema "post_images" do
    belongs_to :post, Post
    belongs_to :image, Image

    timestamps()
  end

  @doc false
  def changeset(post_image, attrs) do
    post_image
    |> cast(attrs, [:post_id, :image_id])
    |> validate_required([:post_id, :image_id])
    |> unique_constraint(:post_id, name: :post_images_post_id_image_id_index)
  end
end
