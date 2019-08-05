defmodule VuePhoenixWeb.RegistrationsView do
  use VuePhoenixWeb, :view

  def render("show.json", token) do
    %{token: token.code}
  end
end
