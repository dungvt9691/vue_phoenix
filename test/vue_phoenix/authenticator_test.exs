defmodule VuePhoenix.AuthenticatorTest do
  use VuePhoenix.DataCase

  alias VuePhoenix.Authenticator

  setup do
    sign_up_params = %{
      email: "dungvt9691@gmail.com",
      password: "password",
      password_confirmation: "password"
    }

    sign_in_params = %{email: "dungvt9691@gmail.com", password: "password"}
    [sign_up_params: sign_up_params, sign_in_params: sign_in_params]
  end

  describe "sign_in" do
    test "successfully", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Authenticator.sign_up(sign_up_params)
      assert {:ok, _} = Authenticator.sign_in(sign_in_params)
    end

    test "email address is not registered", %{sign_in_params: sign_in_params} do
      {:error, reason} = Authenticator.sign_in(sign_in_params)
      assert %{email: "Your email address is not registered"} = reason
    end

    test "password invalid", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Authenticator.sign_up(sign_up_params)
      {:error, reason} = Authenticator.sign_in(%{sign_in_params | password: "123123"})
      assert %{password: "invalid password"} = reason
    end
  end

  describe "sign_out" do
    test "successfully", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Authenticator.sign_up(sign_up_params)

      {:ok, token} = Authenticator.sign_in(sign_in_params)

      assert {:ok, _} = Authenticator.sign_out(token.code)
    end

    test "token not found" do
      assert {:error, _} = Authenticator.sign_out("Fake token")
    end
  end

  describe "sign_up" do
    test "successfully", %{sign_up_params: sign_up_params} do
      assert {:ok, _} = Authenticator.sign_up(sign_up_params)
    end

    test "unsuccessfully", %{sign_up_params: sign_up_params} do
      assert {:error, _} = Authenticator.sign_up(%{sign_up_params | email: "dungvt9691"})
    end
  end
end
