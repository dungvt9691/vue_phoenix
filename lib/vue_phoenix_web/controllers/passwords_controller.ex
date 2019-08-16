defmodule VuePhoenixWeb.PasswordsController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.Identify

  def create(conn, %{"email" => email}) do
    case Identify.forgot_password(email) do
      {:ok, _} ->
        conn |> send_resp(200, "")

      {:error, reason} ->
        conn
        |> put_status(404)
        |> put_view(VuePhoenixWeb.ErrorView)
        |> render("error.json", reason: reason)
    end
  end

  def update(conn, _) do
    case Identify.reset_password(conn.params) do
      {:ok, _} ->
        conn |> send_resp(200, "")

      {:not_found, reason} ->
        conn |> send_resp(404, reason)

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
