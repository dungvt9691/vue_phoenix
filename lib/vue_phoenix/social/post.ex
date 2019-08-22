defmodule VuePhoenix.Social.Post do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.User
  alias VuePhoenix.Social.{Comment, Image}

  schema "posts" do
    belongs_to :user, User
    has_many :comments, Comment
    has_many :images, Image

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
