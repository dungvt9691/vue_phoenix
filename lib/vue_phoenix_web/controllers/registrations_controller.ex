defmodule VuePhoenixWeb.RegistrationsController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.User

  def create(conn, _params) do
    case User.sign_up(conn.params) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("show.json", token: token)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
