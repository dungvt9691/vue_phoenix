defmodule VuePhoenixWeb.TokenViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.TokenView

  test "show.json-api" do
    user = insert(:user)
    token = insert(:token, user: user)
    rendered_token = TokenView.render("show.json-api", %{data: token})

    assert rendered_token["data"]["attributes"] == %{
             "code" => token.code,
             "revoked" => token.revoked,
             "revoked_at" => token.revoked_at
           }
  end
end
