defmodule VuePhoenix.Social.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.User
  alias VuePhoenix.Social.PostImage

  schema "posts" do
    belongs_to :user, User
    has_many :post_images, PostImage
    has_many :images, through: [:post_images, :image]

    field :content, :string
    field :external_id, Ecto.UUID, autogenerate: true

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
