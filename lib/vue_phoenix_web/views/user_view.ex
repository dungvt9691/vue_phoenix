defmodule VuePhoenixWeb.UserView do
  use VuePhoenixWeb, :view
  use JaSerializer.PhoenixView

  attributes([:email, :first_name, :last_name, :full_name, :avatar, :birthday])

  has_many :tokens,
    serializer: VuePhoenixWeb.TokenView,
    include: false,
    identifiers: :when_included

  has_many :posts,
    serializer: VuePhoenixWeb.PostView,
    include: false,
    identifiers: :when_included

  has_many :images,
    serializer: VuePhoenixWeb.ImageView,
    include: false,
    identifiers: :when_included

  def avatar(user, _conn) do
    VuePhoenix.Avatar.urls({user.avatar, user})
  end

  def id(user, _conn) do
    user.external_id
  end

  def full_name(user, _conn) do
    case Enum.join([user.first_name, user.last_name], " ") do
      " " -> nil
      name -> name
    end
  end
end
