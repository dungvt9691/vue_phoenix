defmodule VuePhoenixWeb.ErrorViewTest do
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  alias VuePhoenixWeb.ErrorView

  test "error.json" do
    reason = "This is the reason"
    rendered_error = ErrorView.render("error.json", %{reason: reason})
    assert rendered_error == %{errors: "This is the reason"}
  end
end
