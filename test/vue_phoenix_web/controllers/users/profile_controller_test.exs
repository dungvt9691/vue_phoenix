defmodule VuePhoenixWeb.Users.ProfileControllerTest do
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.Authenticator

  def fixture(:sign_up) do
    {:ok, token} =
      Authenticator.sign_up(%{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      })

    token
  end

  describe "show profile" do
    setup [:sign_up_user]

    test "authorized", %{conn: conn, token: token} do
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/json")
        |> put_req_header("content-type", "application/json")
        |> get(Routes.profile_path(conn, :show))

      assert json_response(conn, 200) == %{
               "email" => "dungvt9691@gmail.com"
             }
    end

    test "unauthorized", %{conn: conn} do
      conn =
        build_conn()
        |> get(Routes.profile_path(conn, :show))

      assert conn.status == 401
      assert conn.resp_body == "Unauthorized"
    end
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
