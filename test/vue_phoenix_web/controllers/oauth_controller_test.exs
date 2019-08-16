defmodule VuePhoenixWeb.OauthControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  import Mock

  setup do
    image_url = "https://test.com/avatar.jpg"

    conn =
      build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    [conn: conn, image_url: image_url]
  end

  describe "create" do
    test "successfully", %{conn: conn, image_url: image_url} do
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
        conn =
          conn
          |> post(Routes.oauth_path(conn, :create), %{
            "access_token" => "token",
            "provider" => "facebook"
          })

        assert conn.status == 200
      end
    end

    test "fail", %{conn: conn} do
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
        conn =
          conn
          |> post(Routes.oauth_path(conn, :create), %{
            "access_token" => "token",
            "provider" => "facebook"
          })

        assert conn.status == 401
      end
    end
  end
end
