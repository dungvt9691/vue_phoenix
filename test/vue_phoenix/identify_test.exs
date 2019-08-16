defmodule VuePhoenix.IdentifyTest do
  @moduledoc false
  use VuePhoenix.DataCase
  use Bamboo.Test

  import Mock
  import VuePhoenix.Factory
  alias VuePhoenix.{Identify, Repo}
  alias VuePhoenix.Identify.{User}
  alias VuePhoenix.Services.SendMail

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

  describe "forgot_password" do
    setup do
      user = insert(:user)
      [user: user]
    end

    test "email address is not registered" do
      assert {:error, _} = Identify.forgot_password("dungvt9691@gmail.com")
    end

    test "successfully", %{user: user} do
      assert {:ok, _} = Identify.forgot_password(user.email)
      assert_delivered_email(SendMail.reset_password_instructions(user))
    end

    test "There is SMTP_FROM variable", %{user: user} do
      System.put_env("SMTP_FROM", "<Vue Phoenix dungvt9691@gmail.com>")
      assert {:ok, _} = Identify.forgot_password(user.email)
      assert_delivered_email(SendMail.reset_password_instructions(user))
    end
  end

  describe "reset_password" do
    setup do
      expire_at =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(86_400)
        |> NaiveDateTime.truncate(:second)

      user = insert(:user, reset_password_expire_at: expire_at)
      token_expired_user = insert(:user, reset_password_expire_at: ~N[2019-01-01 00:00:00])

      reset_password_params = %{
        "reset_password_token" => user.reset_password_token,
        "password" => "password",
        "password_confirmation" => "password"
      }

      [
        user: user,
        token_expired_user: token_expired_user,
        reset_password_params: reset_password_params
      ]
    end

    test "token expired", %{
      token_expired_user: token_expired_user,
      reset_password_params: reset_password_params
    } do
      assert {:not_found, _} =
               Identify.reset_password(%{
                 reset_password_params
                 | "reset_password_token" => token_expired_user.reset_password_token
               })
    end

    test "successfully", %{reset_password_params: reset_password_params} do
      assert {:ok, _} = Identify.reset_password(reset_password_params)
    end

    test "invalid params", %{reset_password_params: reset_password_params} do
      assert {:error, _} = Identify.reset_password(%{reset_password_params | "password" => "123"})
    end
  end

  describe "social_login" do
    setup do
      image_url = "https://test.com/avatar.jpg"

      [image_url: image_url]
    end

    test "fetch Facebook user data success", %{
      image_url: image_url
    } do
      with_mocks([
        {
          HTTPoison,
          [],
          [get!: fn _url -> %HTTPoison.Response{body: File.read!("test/fixtures/sample.jpg")} end]
        },
        {
          Facebook,
          [],
          [
            me: fn _fields, _access_token ->
              {:ok,
               %{
                 "email" => "dungvt9691@gmail.com",
                 "first_name" => "Dung",
                 "middle_name" => "The",
                 "last_name" => "Vu",
                 "birthday" => "06/09/1991",
                 "picture" => %{
                   "data" => %{
                     "url" => image_url
                   }
                 }
               }}
            end
          ]
        }
      ]) do
        Identify.social_login("facebook", "access-token")
        user = Repo.get_by(User, %{email: "dungvt9691@gmail.com"})
        refute nil == user
        assert "dungvt9691@gmail.com" = user.email
        assert "The Dung" = user.first_name
        assert "Vu" = user.last_name
        assert ~N[1991-09-06 00:00:00] = user.birthday
        assert "download.jpg" = user.avatar.file_name
      end
    end

    test "fetch Facebook user data success and email existed", %{
      image_url: image_url
    } do
      with_mocks([
        {
          HTTPoison,
          [],
          [get!: fn _url -> %HTTPoison.Response{body: File.read!("test/fixtures/sample.jpg")} end]
        },
        {
          Facebook,
          [],
          [
            me: fn _fields, _access_token ->
              {:ok,
               %{
                 "email" => "dungvt9691@gmail.com",
                 "first_name" => "Dung",
                 "middle_name" => "The",
                 "last_name" => "Vu",
                 "birthday" => "06/09/1991",
                 "picture" => %{
                   "data" => %{
                     "url" => image_url
                   }
                 }
               }}
            end
          ]
        }
      ]) do
        user = insert(:user, email: "dungvt9691@gmail.com")
        Identify.social_login("facebook", "access-token")
        updated_user = Repo.get_by(User, %{email: "dungvt9691@gmail.com"})
        refute user == updated_user
      end
    end

    test "fetch Facebook user data success and data invalid", %{
      image_url: image_url
    } do
      with_mocks([
        {
          HTTPoison,
          [],
          [get!: fn _url -> raise "error" end]
        },
        {
          Facebook,
          [],
          [
            me: fn _fields, _access_token ->
              {:ok,
               %{
                 "email" => "dungvt9691@gmail.com",
                 "first_name" => "Dung",
                 "middle_name" => "The",
                 "last_name" => "Vu",
                 "birthday" => "1991/09/06",
                 "picture" => %{
                   "data" => %{
                     "url" => image_url
                   }
                 }
               }}
            end
          ]
        }
      ]) do
        Identify.social_login("facebook", "access-token")
        user = Repo.get_by(User, %{email: "dungvt9691@gmail.com"})
        refute nil == user
        assert "dungvt9691@gmail.com" = user.email
        assert "The Dung" = user.first_name
        assert "Vu" = user.last_name
        refute nil = user.birthday
        refute nil = user.avatar
      end
    end

    test "fetch Facebook user data error" do
      with_mocks([
        {
          HTTPoison,
          [],
          [get!: fn _url -> %HTTPoison.Response{body: File.read!("test/fixtures/sample.jpg")} end]
        },
        {
          Facebook,
          [],
          [
            me: fn _fields, _access_token ->
              {:error,
               %{
                 "errors" => %{
                   "code" => 190,
                   "fbtrace_id" => "Ad3Ool8_aQf3FyhPf4nYD9I",
                   "message" => "Malformed access token",
                   "type" => "OAuthException"
                 }
               }}
            end
          ]
        }
      ]) do
        assert {:error,
                %{
                  "errors" => %{
                    "code" => 190,
                    "fbtrace_id" => "Ad3Ool8_aQf3FyhPf4nYD9I",
                    "message" => "Malformed access token",
                    "type" => "OAuthException"
                  }
                }} = Identify.social_login("facebook", "access-token")
      end
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
