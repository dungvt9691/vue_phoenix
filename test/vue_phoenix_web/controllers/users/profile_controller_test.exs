defmodule VuePhoenixWeb.Users.ProfileControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  alias VuePhoenix.{Identify, Repo}
  alias VuePhoenix.Identify.User

  def fixture(:sign_up) do
    {:ok, token} =
      Identify.sign_up(%{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      })

    token
  end

  describe "show profile" do
    setup [:sign_up_user]

    setup %{token: token} do
      include_params = %{"include" => "tokens,posts,images"}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [conn: conn, include_params: include_params]
    end

    test "authorized", %{conn: conn} do
      conn =
        conn
        |> get(Routes.profile_path(conn, :show))

      profile = Repo.get_by!(User, email: "dungvt9691@gmail.com")
      avatar = VuePhoenix.Avatar.urls({profile.avatar, profile})

      assert json_response(conn, 200)["data"]["attributes"] == %{
               "email" => profile.email,
               "avatar" => %{
                 "s100x100" => avatar.s100x100,
                 "s200x200" => avatar.s200x200,
                 "s50x50" => avatar.s50x50
               },
               "birthday" => profile.birthday,
               "first_name" => profile.first_name,
               "last_name" => profile.last_name
             }
    end

    test "show profile with included data", %{conn: conn, include_params: include_params} do
      conn =
        conn
        |> get(Routes.profile_path(conn, :show, include_params))

      assert json_response(conn, 200)["included"]
    end

    test "unauthorized", %{conn: conn} do
      conn =
        build_conn()
        |> get(Routes.profile_path(conn, :show))

      assert conn.status == 401
      assert conn.resp_body == "Unauthorized"
    end
  end

  describe "update profile" do
    setup [:sign_up_user]

    setup do
      valid_attrs = %{
        first_name: "Dung",
        last_name: "Vu",
        birthday: "1991-09-06T00:00:00Z",
        avatar: %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
      }

      invalid_attrs = %{
        first_name: "Dung",
        last_name: "Vu",
        password: "123",
        birthday: "1991-09-06",
        avatar: %Plug.Upload{path: "test/fixtures/sample.bmp", filename: "sample.bmp"}
      }

      [valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attributes", %{conn: conn, token: token, valid_attrs: valid_attrs} do
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")
        |> put(Routes.profile_path(conn, :update), valid_attrs)

      profile = Repo.get_by!(User, email: "dungvt9691@gmail.com")
      avatar = VuePhoenix.Avatar.urls({profile.avatar, profile})

      assert json_response(conn, 200)["data"]["attributes"] == %{
               "email" => profile.email,
               "avatar" => %{
                 "s100x100" => avatar.s100x100,
                 "s200x200" => avatar.s200x200,
                 "s50x50" => avatar.s50x50
               },
               "birthday" => NaiveDateTime.to_iso8601(profile.birthday),
               "first_name" => profile.first_name,
               "last_name" => profile.last_name
             }
    end

    test "invalid attributes", %{conn: conn, token: token, invalid_attrs: invalid_attrs} do
      ExUnit.CaptureLog.capture_log(fn ->
        conn =
          build_conn()
          |> put_req_header("authorization", "Bearer #{token.code}")
          |> put_req_header("accept", "application/vnd.api+json")
          |> put_req_header("content-type", "application/vnd.api+json")
          |> put(Routes.profile_path(conn, :update), invalid_attrs)

        assert json_response(conn, 422) == %{
                 "errors" => %{
                   "birthday" => ["is invalid"],
                   "avatar" => ["is invalid"],
                   "password" => ["should be at least 6 character(s)"],
                   "password_confirmation" => ["does not match with password"]
                 }
               }
      end)
    end
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
