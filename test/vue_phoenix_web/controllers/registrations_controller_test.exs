defmodule VuePhoenixWeb.RegistrationsControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.Identify

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    [conn: conn]
  end

  describe "create" do
    setup do
      sign_up_attrs = %{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      }

      invalid_params = [email: "dungvt9691", password: "123", password_confirmation: "123123"]

      [
        sign_up_attrs: sign_up_attrs,
        invalid_params: invalid_params
      ]
    end

    test "successfully", %{conn: conn, sign_up_attrs: sign_up_attrs} do
      conn =
        conn
        |> post(Routes.registrations_path(conn, :create), sign_up_attrs)

      assert conn.status == 200
    end

    test "failed", %{conn: conn, invalid_params: invalid_params} do
      conn =
        conn
        |> post(Routes.registrations_path(conn, :create), invalid_params)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["has invalid format"],
                 "password" => ["should be at least 6 character(s)"],
                 "password_confirmation" => ["does not match with password"]
               }
             }
    end

    test "email registered", %{
      conn: conn,
      sign_up_attrs: sign_up_attrs
    } do
      Identify.sign_up(sign_up_attrs)

      conn =
        conn
        |> post(Routes.registrations_path(conn, :create), sign_up_attrs)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "email" => ["has already been taken"]
               }
             }
    end
  end
end
