defmodule VuePhoenix.Identify.User do
  @moduledoc false

  use Arc.Ecto.Schema
  use Ecto.Schema
  import Ecto.Changeset

  alias VuePhoenix.Identify.Token
  alias VuePhoenix.Services.Encryption
  alias VuePhoenix.Social.{Image, Post}

  @email_regex ~r/(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)/

  schema "users" do
    has_many :tokens, Token
    has_many :posts, Post
    has_many :images, Image

    # FIELDS
    field :external_id, Ecto.UUID, autogenerate: true
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :avatar, VuePhoenix.Avatar.Type
    field :birthday, :naive_datetime
    field :encrypted_password, :string
    field :reset_password_token, :string
    field :reset_password_sent_at, :naive_datetime

    # VIRTUAL FIELDS
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, @email_regex)
    |> validate_length(:password, min: 6)
    |> validate_password_confirmation
    |> encrypt_password
  end

  @doc false
  def changeset_for_update(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :birthday
    ])
    |> cast_attachments(attrs, [:avatar])
    |> validate_length(:password, min: 6)
    |> validate_password_confirmation
    |> encrypt_password
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

  defp validate_password_confirmation(changeset) do
    password = get_change(changeset, :password)
    password_confirmation = get_change(changeset, :password_confirmation)

    if password && password != password_confirmation do
      add_error(changeset, :password_confirmation, "does not match with password")
    else
      changeset
    end
  end
end
