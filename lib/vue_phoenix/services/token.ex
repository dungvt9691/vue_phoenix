defmodule VuePhoenix.Services.Token do
  @moduledoc false

  alias VuePhoenixWeb.Endpoint
  @seed "user salt"

  def generate(id) do
    Phoenix.Token.sign(Endpoint.config(:secret_key_base), @seed, id, max_age: 86_400)
  end

  def get(conn) do
    case extract(conn) do
      {:ok, token} -> verify(token)
      error -> error
    end
  end

  defp verify(token) do
    case Phoenix.Token.verify(Endpoint.config(:secret_key_base), @seed, token, max_age: 86_400) do
      {:ok, _id} -> {:ok, token}
      error -> error
    end
  end

  defp extract(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [auth_header] -> get_from_header(auth_header)
      _ -> {:error, :missing_auth_header}
    end
  end

  defp get_from_header(auth_header) do
    {:ok, reg} = Regex.compile("Bearer\:?\s+(.*)$", "i")

    case Regex.run(reg, auth_header) do
      [_, match] -> {:ok, String.trim(match)}
      _ -> {:error, "Missing token."}
    end
  end
end
