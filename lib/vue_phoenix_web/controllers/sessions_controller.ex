defmodule VuePhoenixWeb.SessionsController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.Authenticator

  def create(conn, %{"email" => email, "password" => password}) do
    case Authenticator.sign_in(%{email: email, password: password}) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("show.json", token: token)

      {:error, reason} ->
        conn
        |> put_status(401)
        |> put_view(VuePhoenixWeb.ErrorView)
        |> render("error.json", reason: reason)
    end
  end

  @spec delete(Plug.Conn.t(), any) :: Plug.Conn.t()
  def delete(conn, _) do
    case Authenticator.sign_out(conn.assigns[:current_token]) do
      {:error, reason} ->
        conn |> send_resp(400, reason)

      {:ok, _} ->
        conn |> send_resp(204, "")
    end
  end
end