defmodule VuePhoenixWeb.Users.ProfileView do
  use VuePhoenixWeb, :view

  def render("show.json", %{profile: profile}) do
    render_one(profile, VuePhoenixWeb.Users.ProfileView, "profile.json")
  end

  def render("profile.json", %{profile: profile}) do
    %{
      email: profile.email,
      first_name: profile.first_name,
      last_name: profile.last_name,
      birthday: profile.birthday,
      avatar: VuePhoenix.Image.urls({profile.avatar, profile})
    }
  end
end
