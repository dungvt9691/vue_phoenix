defmodule VuePhoenix.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias VuePhoenix.{Repo, User, Token}
  alias VuePhoenix.Services.{Encryption, Authenticator}

  schema "users" do
    has_many :tokens, Token

    # FIELDS
    field :email, :string
    field :encrypted_password, :string
    field :reset_password_token, :string
    field :reset_password_sent_at, :utc_datetime

    # VIRTUAL FIELDS
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)/)
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, required: true)
    |> encrypt_password
  end

  def sign_in(%{email: email, password: password}) do
    case Repo.get_by(User, %{email: email}) do
      nil -> {:error, %{email: "Your email address is not registered"}}
      user ->
        case Encryption.validate_password(user, password) do
          {:ok, user} ->
            token = Authenticator.generate_token(user)
            user
            |> Ecto.build_assoc(:tokens, %{code: token})
            |> Repo.insert
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
        code = Authenticator.generate_token(user)
        user
        |> Ecto.build_assoc(:tokens, %{code: code})
        |> Repo.insert
      error -> error
    end
  end

  defp encrypt_password(changeset) do
    password = get_change(changeset, :password)
    if password do
      encrypted_password = Encryption.hash_password(password)
      put_change(changeset, :encrypted_password, encrypted_password)
    else
      changeset
    end
  end
end
