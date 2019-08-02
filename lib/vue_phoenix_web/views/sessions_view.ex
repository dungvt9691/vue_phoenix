defmodule VuePhoenixWeb.SessionsView do
  use VuePhoenixWeb, :view

  def render("show.json", token) do
    %{data: %{token: token.code}}
  end
end
