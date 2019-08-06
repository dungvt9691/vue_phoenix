defmodule VuePhoenix.TokenTest do
  use VuePhoenix.DataCase

  alias VuePhoenix.{User, Token, Repo}

  describe "changeset" do
    @valid_attrs %{code: "code", user_id: 1}
    @invalid_attrs %{code: ""}
    @user_attrs %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}

    test "changeset with valid attributes" do
      changeset = Token.changeset(%Token{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Token.changeset(%Token{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with code existed" do
      {:ok, user} = User.changeset(%User{}, @user_attrs)
                    |> Repo.insert

      user
      |> Ecto.build_assoc(:tokens, @valid_attrs)
      |> Repo.insert

      changeset = Token.changeset(%Token{}, @valid_attrs)

      {:error, changeset} = Repo.insert(changeset)

      assert %{code: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
