defmodule VuePhoenix.Plugs.Authenticate do
  @moduledoc false

  import Plug.Conn

  alias VuePhoenix.Identify.Token
  alias VuePhoenix.Repo
  alias VuePhoenix.Services.Token, as: TokenService

  def init(default), do: default

  def call(conn, _default) do
    case TokenService.get(conn) do
      {:ok, code} ->
        token = Repo.get_by(Token, %{code: code, revoked: false})

        case token |> Repo.preload(:user) do
          nil -> unauthorized(conn)
          token -> authorized(conn, token.user, token)
        end

      _ ->
        unauthorized(conn)
    end
  end

  defp authorized(conn, user, token) do
    # If you want, add new values to `conn`
    conn
    |> assign(:signed_user, user)
    |> assign(:current_token, token.code)
  end

  defp unauthorized(conn) do
    conn |> send_resp(401, "Unauthorized") |> halt()
  end
end
