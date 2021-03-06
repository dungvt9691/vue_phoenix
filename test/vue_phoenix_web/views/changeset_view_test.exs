defmodule VuePhoenixWeb.ChangesetViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  alias VuePhoenix.Identify.User
  alias VuePhoenixWeb.ChangesetView

  test "error.json" do
    changeset =
      User.changeset(%User{}, %{
        email: "dungvt9691",
        password: "123",
        password_confirmation: "123123"
      })

    rendered_error = ChangesetView.render("error.json", %{changeset: changeset})

    assert rendered_error == %{
             errors: %{
               email: ["has invalid format"],
               password: ["should be at least 6 character(s)"],
               password_confirmation: ["does not match with password"]
             }
           }
  end
end
