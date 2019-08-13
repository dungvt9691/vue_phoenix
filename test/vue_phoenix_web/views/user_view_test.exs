defmodule VuePhoenixWeb.UserViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.UserView

  test "show.json-api" do
    profile = insert(:user)
    rendered_profile = UserView.render("show.json-api", data: profile)

    assert rendered_profile["data"]["attributes"] == %{
             "email" => profile.email,
             "avatar" => VuePhoenix.Avatar.urls({profile.avatar, profile}),
             "birthday" => profile.birthday,
             "first_name" => profile.first_name,
             "last_name" => profile.last_name
           }
  end
end
