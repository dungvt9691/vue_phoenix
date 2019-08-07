defmodule VuePhoenixWeb.Users.ProfileController do
  use VuePhoenixWeb, :controller

  def show(conn, _) do
    conn
    |> put_status(:ok)
    |> render("show.json", profile: conn.assigns[:signed_user])
  end
end
