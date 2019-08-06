defmodule VuePhoenix.UserTest do
  use VuePhoenix.DataCase

  alias VuePhoenix.User

  describe "changeset" do
    @valid_attrs %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}

    test "changeset with valid attributes" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with email invalid" do
      changeset = User.changeset(%User{}, %{@valid_attrs | email: "dungvt9691"})
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end

    test "changeset with email existed" do
      User.sign_up(@valid_attrs)
      {:error, changeset} = User.sign_up(@valid_attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "changeset with password invalid" do
      changeset = User.changeset(%User{}, %{@valid_attrs | password: "pwd"})
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
    end

    test "changeset with password not match" do
      changeset = User.changeset(%User{}, %{@valid_attrs | password_confirmation: "password1"})
      assert %{password_confirmation: ["does not match confirmation"]} = errors_on(changeset)
    end
  end

  describe "sign_in" do
    @sign_up_params %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}
    @sign_in_params %{email: "dungvt9691@gmail.com", password: "password"}

    test "successfully" do
      User.sign_up(@sign_up_params)
      assert {:ok, _} = User.sign_in(@sign_in_params)
    end

    test "email address is not registered" do
      {:error, reason} = User.sign_in(@sign_in_params)
      assert %{email: "Your email address is not registered"} = reason
    end

    test "password invalid" do
      User.sign_up(@sign_up_params)
      {:error, reason} = User.sign_in(%{@sign_in_params | password: "123123"})
      assert %{password: "invalid password"} = reason
    end
  end

  describe "sign_out" do
    @sign_up_params %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}
    @sign_in_params %{email: "dungvt9691@gmail.com", password: "password"}

    test "successfully" do
      User.sign_up(@sign_up_params)

      {:ok, token} = User.sign_in(@sign_in_params)

      assert {:ok, _} = User.sign_out(token.code)
    end

    test "token not found" do
      assert {:error, _} = User.sign_out("Fake token")
    end
  end

  describe "sign_up" do
    @sign_up_params %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}

    test "successfully" do
      assert {:ok, _} = User.sign_up(@sign_up_params)
    end

    test "unsuccessfully" do
      assert {:error, _} = User.sign_up(%{@sign_up_params | email: "dungvt9691"})
    end
  end
end
