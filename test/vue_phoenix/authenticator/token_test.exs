defmodule VuePhoenix.Authenticator.TokenTest do
  use VuePhoenix.DataCase

  import VuePhoenix.Factory

  alias VuePhoenix.Authenticator.Token
  alias VuePhoenix.Repo

  describe "changeset" do
    setup do
      valid_attrs = %{code: "code", user_id: 1}
      invalid_attrs = %{code: ""}
      [valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = Token.changeset(%Token{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes", %{invalid_attrs: invalid_attrs} do
      changeset = Token.changeset(%Token{}, invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with code existed", %{valid_attrs: valid_attrs} do
      user = insert(:user)

      user
      |> Ecto.build_assoc(:tokens, valid_attrs)
      |> Repo.insert()

      changeset = Token.changeset(%Token{}, valid_attrs)

      {:error, changeset} = Repo.insert(changeset)

      assert %{code: ["has already been taken"]} = errors_on(changeset)
    end
  end
end
