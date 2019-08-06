defmodule VuePhoenixWeb.Users.SessionsControllerTest do
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.{User, Repo}

  @user_attrs %{email: "dungvt9691@gmail.com", password: "password", password_confirmation: "password"}
  @sign_in_params [email: "dungvt9691@gmail.com", password: "password"]
  @existed_email_params [email: "not-registered@gmail.com", password: "password"]
  @invalid_password_params [email: "dungvt9691@gmail.com", password: "invalid"]

  def fixture(:user) do
    {:ok, user} = User.changeset(%User{}, @user_attrs)
                |> Repo.insert
    user
  end

  def fixture(:sign_up) do
    {:ok, token} = User.sign_up(@user_attrs)
    token
  end

  describe "create" do
    setup [:create_user]

    test "successfully", %{conn: conn} do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(Routes.sessions_path(conn, :create), @sign_in_params)
      assert conn.status == 200
    end

    test "email is not registered", %{conn: conn} do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(Routes.sessions_path(conn, :create), @existed_email_params)
      assert json_response(conn, 401) == %{
        "errors" => %{
          "email" => "Your email address is not registered"
        }
      }
    end

    test "invalid password", %{conn: conn} do
      conn = build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> post(Routes.sessions_path(conn, :create), @invalid_password_params)
      assert json_response(conn, 401) == %{
        "errors" => %{
          "password" => "invalid password"
        }
      }
    end
  end

  describe "delete" do
    setup [:sign_up_user]

    test "successfully", %{conn: conn, token: token} do
      conn = build_conn()
      |> put_req_header("authorization", "Bearer #{token.code}")
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> delete(Routes.sessions_path(conn, :delete))
      assert conn.status == 204
    end

    test "unauthorized", %{conn: conn} do
      conn = build_conn()
      |> put_req_header("authorization", "Bearer abc")
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> delete(Routes.sessions_path(conn, :delete))
      assert conn.status == 401
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
