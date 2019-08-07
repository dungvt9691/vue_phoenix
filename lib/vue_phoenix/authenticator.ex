defmodule VuePhoenix.Authenticator do
  @moduledoc """
    The Authenticator context.
  """
  alias VuePhoenix.Repo
  alias VuePhoenix.Authenticator.{Token, User}
  alias VuePhoenix.Services.Encryption
  alias VuePhoenix.Services.Token, as: TokenService

  def sign_in(%{email: email, password: password}) do
    case Repo.get_by(User, %{email: email}) do
      nil ->
        {:error, %{email: "Your email address is not registered"}}

      user ->
        case Encryption.validate_password(user, password) do
          {:ok, user} ->
            token = TokenService.generate(user)

            user
            |> Ecto.build_assoc(:tokens, %{code: token})
            |> Repo.insert()

          {:error, reason} ->
            {:error, %{password: reason}}
        end
    end
  end

  def sign_out(token) do
    case Repo.get_by(Token, %{code: token}) do
      nil -> {:error, :not_found}
      token -> Repo.delete(token)
    end
  end

  def sign_up(params) do
    changeset = User.changeset(%User{}, params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        code = TokenService.generate(user)

        user
        |> Ecto.build_assoc(:tokens, %{code: code})
        |> Repo.insert()

      error ->
        error
    end
  end
end
