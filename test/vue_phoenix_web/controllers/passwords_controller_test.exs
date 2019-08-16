defmodule VuePhoenixWeb.PasswordsControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase
  use Bamboo.Test

  import VuePhoenix.Factory

  alias VuePhoenix.Services.SendMail

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    [conn: conn]
  end

  describe "create" do
    setup do
      user = insert(:user)
      [user: user]
    end

    test "successfully", %{conn: conn, user: user} do
      conn =
        conn
        |> post(Routes.passwords_path(conn, :create), %{"email" => user.email})

      assert conn.status == 200
      assert_delivered_email(SendMail.reset_password_instructions(user))
    end

    test "failed", %{conn: conn} do
      conn =
        conn
        |> post(Routes.passwords_path(conn, :create), %{"email" => "dungvt9691@gmail.com"})

      assert json_response(conn, 404) == %{
               "errors" => %{
                 "email" => "Your email address is not registered"
               }
             }
    end
  end

  describe "update" do
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

    test "successfully", %{conn: conn, reset_password_params: reset_password_params} do
      conn =
        conn
        |> put(Routes.passwords_path(conn, :update), reset_password_params)

      assert conn.status == 200
    end

    test "token expired", %{
      conn: conn,
      token_expired_user: token_expired_user,
      reset_password_params: reset_password_params
    } do
      conn =
        conn
        |> put(Routes.passwords_path(conn, :update), %{
          reset_password_params
          | "reset_password_token" => token_expired_user.reset_password_token
        })

      assert conn.status == 404
    end

    test "invalid params", %{conn: conn, reset_password_params: reset_password_params} do
      conn =
        conn
        |> put(Routes.passwords_path(conn, :update), %{
          reset_password_params
          | "password" => "123"
        })

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "password" => ["should be at least 6 character(s)"],
                 "password_confirmation" => ["does not match with password"]
               }
             }
    end
  end
end
