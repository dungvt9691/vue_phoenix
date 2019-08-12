defmodule VuePhoenix.IdentifyTest do
  @moduledoc false
  use VuePhoenix.DataCase

  import VuePhoenix.Factory
  alias VuePhoenix.Identify

  setup do
    sign_up_params = %{
      email: "dungvt9691@gmail.com",
      password: "password",
      password_confirmation: "password"
    }

    update_params = %{
      first_name: "Dung",
      last_name: "Vu",
      birthday: "1991-09-06T00:00:00",
      avatar: %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
    }

    sign_in_params = %{email: "dungvt9691@gmail.com", password: "password"}
    [sign_up_params: sign_up_params, sign_in_params: sign_in_params, update_params: update_params]
  end

  describe "sign_in" do
    test "successfully", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Identify.sign_up(sign_up_params)
      assert {:ok, _} = Identify.sign_in(sign_in_params)
    end

    test "email address is not registered", %{sign_in_params: sign_in_params} do
      {:error, reason} = Identify.sign_in(sign_in_params)
      assert %{email: "Your email address is not registered"} = reason
    end

    test "password invalid", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Identify.sign_up(sign_up_params)
      {:error, reason} = Identify.sign_in(%{sign_in_params | password: "123123"})
      assert %{password: "invalid password"} = reason
    end
  end

  describe "sign_out" do
    test "successfully", %{sign_up_params: sign_up_params, sign_in_params: sign_in_params} do
      Identify.sign_up(sign_up_params)

      {:ok, token} = Identify.sign_in(sign_in_params)

      assert {:ok, _} = Identify.sign_out(token.code)
    end

    test "token not found" do
      assert {:error, _} = Identify.sign_out("Fake token")
    end
  end

  describe "sign_up" do
    test "successfully", %{sign_up_params: sign_up_params} do
      assert {:ok, _} = Identify.sign_up(sign_up_params)
    end

    test "unsuccessfully", %{sign_up_params: sign_up_params} do
      assert {:error, _} = Identify.sign_up(%{sign_up_params | email: "dungvt9691"})
    end
  end

  describe "update" do
    setup do
      user = insert(:user)
      [user: user]
    end

    test "successfully", %{user: user, update_params: update_params} do
      assert {:ok, _} = Identify.update(user, update_params)
    end

    test "unsuccessfully", %{user: user, update_params: update_params} do
      assert {:error, _} = Identify.update(user, %{update_params | birthday: "1991-09-06"})
    end
  end
end
