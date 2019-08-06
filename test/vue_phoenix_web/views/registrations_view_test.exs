defmodule VuePhoenixWeb.RegistrationsViewTest do
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.RegistrationsView

  test "show.json" do
    user = insert(:user)
    token = insert(:token, user: user)
    rendered_token = RegistrationsView.render("show.json", %{token: token})
    assert rendered_token == %{token: "code"}
  end
end
