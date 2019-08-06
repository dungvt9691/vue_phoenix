defmodule VuePhoenixWeb.Users.ProfileViewTest do
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.Users.ProfileView

  test "show.json" do
    user = insert(:user)
    rendered_profile = ProfileView.render("show.json", profile: user)
    assert rendered_profile == %{email: "dungvt9691@gmail.com"}
  end

  test "profile.json" do
    user = insert(:user)
    rendered_profile = ProfileView.render("profile.json", profile: user)
    assert rendered_profile == %{email: "dungvt9691@gmail.com"}
  end
end
