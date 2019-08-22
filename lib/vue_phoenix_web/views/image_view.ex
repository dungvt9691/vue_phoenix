defmodule VuePhoenixWeb.ImageView do
  use VuePhoenixWeb, :view
  use JaSerializer.PhoenixView

  attributes([:attachment, :inserted_at, :updated_at])

  has_one :user,
    serializer: VuePhoenixWeb.Users.ProfileView,
    include: false,
    identifiers: :when_included

  has_one :post,
    serializer: VuePhoenixWeb.PostView,
    include: false,
    identifiers: :when_included

  def attachment(image, _conn) do
    VuePhoenix.Image.urls({image.attachment, image})
  end

  def id(image, _conn) do
    image.external_id
  end
end
