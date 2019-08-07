defmodule VuePhoenixWeb.RegistrationsControllerTest do
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.Authenticator

  describe "create" do
    setup do
      sign_up_attrs = %{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      }

      sign_up_params = [
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      ]

      invalid_params = [email: "dungvt9691", password: "123", password_confirmation: "123123"]

      [
        sign_up_attrs: sign_up_attrs,
        sign_up_params: sign_up_params,
        invalid_params: invalid_params
      ]
    end

    test "successfully", %{conn: conn, sign_up_params: sign_up_params} do
      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> post(Routes.registrations_path(conn, :create), sign_up_params)

      assert conn.status == 200
    end

    test "failed", %{conn: conn, invalid_params: invalid_params} do
      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> post(Routes.registrations_path(conn, :create), invalid_params)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["has invalid format"],
                 "password" => ["should be at least 6 character(s)"],
                 "password_confirmation" => ["does not match confirmation"]
               }
             }
    end

    test "email registered", %{
      conn: conn,
      sign_up_attrs: sign_up_attrs,
      sign_up_params: sign_up_params
    } do
      Authenticator.sign_up(sign_up_attrs)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> post(Routes.registrations_path(conn, :create), sign_up_params)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["has already been taken"]
               }
             }
    end
  end
end
