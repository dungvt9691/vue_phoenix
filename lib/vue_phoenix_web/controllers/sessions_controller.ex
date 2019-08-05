defmodule VuePhoenixWeb.SessionsController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.User

  def create(conn, %{"email" => email, "password" => password}) do
    case User.sign_in(email, password) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("show.json", token)
      {:error, reason} ->
        conn
        |> put_status(401)
        |> put_view(VuePhoenixWeb.ErrorView)
        |> render("error.json", reason: reason)
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _) do
    case User.sign_out(conn) do
      {:error, reason} -> conn |> send_resp(400, reason)
      {:ok, _} -> conn |> send_resp(204, "")
    end
  end
end
