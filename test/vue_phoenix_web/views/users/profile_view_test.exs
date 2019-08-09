defmodule VuePhoenixWeb.Users.ProfileViewTest do
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.Users.ProfileView

  test "show.json" do
    profile = insert(:user)
    rendered_profile = ProfileView.render("show.json", profile: profile)

    assert rendered_profile == %{
             email: profile.email,
             avatar: VuePhoenix.Image.urls({profile.avatar, profile}),
             birthday: profile.birthday,
             first_name: profile.first_name,
             last_name: profile.last_name
           }
  end

  test "profile.json" do
    profile = insert(:user)
    rendered_profile = ProfileView.render("profile.json", profile: profile)

    assert rendered_profile == %{
             email: profile.email,
             avatar: VuePhoenix.Image.urls({profile.avatar, profile}),
             birthday: profile.birthday,
             first_name: profile.first_name,
             last_name: profile.last_name
           }
  end
end
