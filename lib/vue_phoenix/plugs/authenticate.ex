defmodule VuePhoenix.Plugs.Authenticate do
  import Plug.Conn

  alias VuePhoenix.{Repo, Token}

  def init(default), do: default

  def call(conn, _default) do
    case VuePhoenix.Services.Authenticator.get_token(conn) do
      {:ok, token} ->
        case Repo.get_by(Token, %{code: token, revoked: false}) |> Repo.preload(:user) do
          nil -> unauthorized(conn)
          token -> authorized(conn, token.user, token)
        end
      _ -> unauthorized(conn)
    end
  end

  defp authorized(conn, user, token) do
    # If you want, add new values to `conn`
    conn
    |> assign(:signed_in, true)
    |> assign(:signed_user, user)
    |> assign(:current_token, token.code)
  end

  defp unauthorized(conn) do
    conn |> send_resp(401, "Unauthorized") |> halt()
  end
end
