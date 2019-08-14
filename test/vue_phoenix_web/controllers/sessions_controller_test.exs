defmodule VuePhoenixWeb.SessionsControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.{Identify, Repo}
  alias VuePhoenix.Identify.{Token, User}

  @user_attrs %{
    email: "dungvt9691@gmail.com",
    password: "password",
    password_confirmation: "password"
  }

  def fixture(:user) do
    changeset = User.changeset(%User{}, @user_attrs)
    {:ok, user} = changeset |> Repo.insert()
    user
  end

  def fixture(:sign_up) do
    {:ok, token} = Identify.sign_up(@user_attrs)
    token
  end

  setup do
    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    [conn: conn]
  end

  describe "create" do
    setup do
      sign_in_params = %{email: "dungvt9691@gmail.com", password: "password"}
      existed_email_params = %{email: "not-registered@gmail.com", password: "password"}
      invalid_password_params = %{email: "dungvt9691@gmail.com", password: "invalid"}

      [
        sign_in_params: sign_in_params,
        existed_email_params: existed_email_params,
        invalid_password_params: invalid_password_params
      ]
    end

    setup [:create_user]

    test "successfully", %{conn: conn, sign_in_params: sign_in_params} do
      conn =
        conn
        |> post(Routes.sessions_path(conn, :create), sign_in_params)

      assert conn.status == 200
    end

    test "email is not registered", %{conn: conn, existed_email_params: existed_email_params} do
      conn =
        conn
        |> post(Routes.sessions_path(conn, :create), existed_email_params)

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "email" => "Your email address is not registered"
               }
             }
    end

    test "invalid password", %{conn: conn, invalid_password_params: invalid_password_params} do
      conn =
        conn
        |> post(Routes.sessions_path(conn, :create), invalid_password_params)

      assert json_response(conn, 401) == %{
               "errors" => %{
                 "password" => "invalid password"
               }
             }
    end
  end

  describe "delete" do
    setup [:sign_up_user]

    test "token revoked", %{conn: conn, token: token} do
      current_time =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)

      token
      |> Token.changeset_for_update(%{
        "revoked" => true,
        "revoked_at" => current_time
      })
      |> Repo.update()

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> delete(Routes.sessions_path(conn, :delete))

      assert conn.status == 401
    end

    test "successfully", %{conn: conn, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> delete(Routes.sessions_path(conn, :delete))

      assert conn.status == 204
    end

    test "unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer abc")
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
