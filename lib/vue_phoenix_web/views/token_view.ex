defmodule VuePhoenixWeb.TokenView do
  use VuePhoenixWeb, :view
  use JaSerializer.PhoenixView

  attributes([:code, :revoked, :revoked_at])

  def id(token, _conn) do
    token.external_id
  end
end
