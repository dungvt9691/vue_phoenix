defmodule VuePhoenix.Identify do
  @moduledoc """
    The Identify context.
  """
  import Ecto.Query

  alias VuePhoenix.{Mailer, Repo}
  alias VuePhoenix.Identify.{Token, User}
  alias VuePhoenix.Services.{Encryption, SendMail}
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
            |> Repo.preload([:user])
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
        |> Repo.preload([:user])
        |> Repo.insert()

      error ->
        error
    end
  end

  def forgot_password(email) do
    case Repo.get_by(User, %{email: email}) do
      nil ->
        {:error, %{email: "Your email address is not registered"}}

      user ->
        user
        |> User.changeset_for_reset_password()
        |> Repo.update()

        user
        |> SendMail.reset_password_instructions()
        |> Mailer.deliver_later()

        {:ok, user}
    end
  end

  def reset_password(params) do
    current_date =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    query =
      from u in User,
        where:
          u.reset_password_token == ^params["reset_password_token"] and
            u.reset_password_expire_at > ^current_date

    case Repo.one(query) do
      nil ->
        {:not_found, "Your reset password token is expired or invalid"}

      user ->
        user
        |> User.changeset_for_update_password(params)
        |> Repo.update()
    end
  end

  def update(user, params) do
    user
    |> User.changeset_for_update(params)
    |> Repo.update()
  end
end
