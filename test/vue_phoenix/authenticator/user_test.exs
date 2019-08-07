defmodule VuePhoenix.Authenticator.UserTest do
  use VuePhoenix.DataCase

  alias VuePhoenix.Authenticator.User

  describe "changeset" do
    setup do
      valid_attrs = %{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      }

      [valid_attrs: valid_attrs]
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      changeset = User.changeset(%User{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with email invalid", %{valid_attrs: valid_attrs} do
      changeset = User.changeset(%User{}, %{valid_attrs | email: "dungvt9691"})
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end

    test "changeset with email existed", %{valid_attrs: valid_attrs} do
      changeset = User.changeset(%User{}, valid_attrs)
      changeset |> Repo.insert()

      changeset = User.changeset(%User{}, valid_attrs)

      {:error, changeset} = Repo.insert(changeset)

      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "changeset with password invalid", %{valid_attrs: valid_attrs} do
      changeset = User.changeset(%User{}, %{valid_attrs | password: "pwd"})
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end

    test "changeset with password not match", %{valid_attrs: valid_attrs} do
      changeset = User.changeset(%User{}, %{valid_attrs | password_confirmation: "password1"})
      assert %{password_confirmation: ["does not match confirmation"]} = errors_on(changeset)
    end
  end
end
