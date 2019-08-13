defmodule VuePhoenixWeb.PostView do
  use VuePhoenixWeb, :view
  use JaSerializer.PhoenixView

  attributes([:content, :inserted_at, :updated_at])

  has_one :user,
    serializer: VuePhoenixWeb.UserView,
    include: false,
    identifiers: :when_included

  has_many :images,
    serializer: VuePhoenixWeb.ImageView,
    include: false,
    identifiers: :when_included

  def id(post, _conn) do
    post.external_id
  end
end
