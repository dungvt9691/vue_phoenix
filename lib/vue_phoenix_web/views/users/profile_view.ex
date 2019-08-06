defmodule VuePhoenixWeb.Users.ProfileView do
  use VuePhoenixWeb, :view

  def render("show.json", %{profile: profile}) do
    render_one(profile, VuePhoenixWeb.Users.ProfileView, "profile.json")
  end

  def render("profile.json", %{profile: profile}) do
    %{
      email: profile.email,
    }
  end
end
