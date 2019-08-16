defmodule VuePhoenixWeb.OauthController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.Identify

  def create(conn, %{"access_token" => access_token, "provider" => provider}) do
    case Identify.social_login(provider, access_token) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("show.json-api", data: token)

      {:error, reason} ->
        conn
        |> put_status(401)
        |> put_view(VuePhoenixWeb.ErrorView)
        |> render("error.json", reason: reason)
    end
  end
end
