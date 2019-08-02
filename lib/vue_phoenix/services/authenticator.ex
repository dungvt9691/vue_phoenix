defmodule VuePhoenix.Services.Authenticator do
  alias VuePhoenixWeb.Endpoint
  @seed "user salt"

  def generate_token(id) do
    Phoenix.Token.sign(Endpoint.config(:secret_key_base), @seed, id, max_age: 86400)
  end

  def verify_token(token) do
    case Phoenix.Token.verify(Endpoint.config(:secret_key_base), @seed, token, max_age: 86400) do
      {:ok, _id} -> {:ok, token}
      error -> error
    end
  end

  def get_token(conn) do
    case extract_token(conn) do
      {:ok, token} -> verify_token(token)
      error -> error
    end
  end

  defp extract_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [auth_header] -> get_token_from_header(auth_header)
       _ -> {:error, :missing_auth_header}
    end
  end

  defp get_token_from_header(auth_header) do
    {:ok, reg} = Regex.compile("Bearer\:?\s+(.*)$", "i")
    case Regex.run(reg, auth_header) do
      [_, match] -> {:ok, String.trim(match)}
      _ -> {:error, "Missing token."}
    end
  end
end
