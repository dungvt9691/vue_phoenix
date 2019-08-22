defmodule VuePhoenixWeb.ImageControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  import VuePhoenix.Factory
  alias VuePhoenix.{Identify, Repo}
  alias VuePhoenix.Social.Image

  def fixture(:sign_up) do
    {:ok, token} =
      Identify.sign_up(%{
        email: "dungvt9691@gmail.com",
        password: "password",
        password_confirmation: "password"
      })

    token
  end

  setup [:sign_up_user]

  describe "index" do
    setup %{token: token} do
      post = insert(:post, user: token.user)
      insert_list(10, :image, user: token.user, post: post)
      pagination_params = %{"page" => 1, "limit" => 2}
      include_params = %{"include" => "user", "fields" => %{}}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [pagination_params: pagination_params, include_params: include_params, conn: conn]
    end

    test "lists all entries on index", %{conn: conn} do
      conn =
        conn
        |> get(Routes.image_path(conn, :index))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 10
    end

    test "lists entries by page and limit", %{
      conn: conn,
      pagination_params: pagination_params
    } do
      conn =
        conn
        |> get(Routes.image_path(conn, :index, pagination_params))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 2
    end

    test "lists entries with included", %{
      conn: conn,
      include_params: include_params
    } do
      conn =
        conn
        |> get(Routes.image_path(conn, :index, include_params))

      assert json_response(conn, 200)["data"]

      assert Enum.map(json_response(conn, 200)["included"], fn include -> include["type"] end) ==
               ["user"]
    end

    test "lists entries with fields", %{
      conn: conn,
      include_params: include_params
    } do
      conn =
        conn
        |> get(
          Routes.image_path(conn, :index, %{include_params | "fields" => %{"user" => "email"}})
        )

      assert json_response(conn, 200)["data"]

      assert Enum.map(json_response(conn, 200)["included"], fn include ->
               Map.keys(include["attributes"])
             end) ==
               [["email"]]
    end
  end

  describe "create" do
    setup %{token: token} do
      valid_attrs = %{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
      }

      invalid_attrs = %{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.bmp", filename: "sample.bmp"}
      }

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [conn: conn, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attrs", %{conn: conn, valid_attrs: valid_attrs} do
      conn =
        conn
        |> post(Routes.image_path(conn, :create), valid_attrs)

      assert json_response(conn, 200)
    end

    test "invalid attrs", %{conn: conn, invalid_attrs: invalid_attrs} do
      ExUnit.CaptureLog.capture_log(fn ->
        conn =
          conn
          |> post(Routes.image_path(conn, :create), invalid_attrs)

        assert json_response(conn, 422) == %{
                 "errors" => %{
                   "attachment" => ["is invalid"]
                 }
               }
      end)
    end
  end

  describe "show" do
    setup %{token: token} do
      post = insert(:post, user: token.user)
      insert(:image, user: token.user)
      image = insert(:image, user: token.user, post: post)
      next_image = insert(:image, user: token.user, post: post)
      last_image = insert(:image, user: token.user)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [
        post: post,
        image: image,
        next_image: next_image,
        last_image: last_image,
        conn: conn
      ]
    end

    test "successfully", %{image: image, conn: conn} do
      conn =
        conn
        |> get(Routes.image_path(conn, :show, image.external_id))

      assert json_response(conn, 200)["data"]
    end

    test "not found", %{conn: conn} do
      conn =
        conn
        |> get(Routes.image_path(conn, :show, "aaa-bbb"))

      assert conn.status == 404
    end

    test "siblings meta without post_id", %{
      image: image,
      next_image: next_image,
      last_image: last_image,
      conn: conn
    } do
      conn =
        conn
        |> get(Routes.image_path(conn, :show, next_image.external_id))

      assert json_response(conn, 200)["meta"]["siblings"] == %{
               "prev" => image.external_id,
               "next" => last_image.external_id
             }
    end

    test "siblings meta with post_id and there is not prev image", %{
      post: post,
      image: image,
      next_image: next_image,
      conn: conn
    } do
      conn =
        conn
        |> get(Routes.image_path(conn, :show, next_image.external_id, post_id: post.external_id))

      assert json_response(conn, 200)["meta"]["siblings"] == %{
               "prev" => image.external_id,
               "next" => image.external_id
             }
    end

    test "siblings meta with post_id and there is not next image", %{
      post: post,
      image: image,
      next_image: next_image,
      conn: conn
    } do
      conn =
        conn
        |> get(Routes.image_path(conn, :show, image.external_id, post_id: post.external_id))

      assert json_response(conn, 200)["meta"]["siblings"] == %{
               "prev" => next_image.external_id,
               "next" => next_image.external_id
             }
    end
  end

  describe "delete" do
    setup %{token: token} do
      image = insert(:image, user: token.user)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [image: image, conn: conn]
    end

    test "successfully", %{image: image, conn: conn} do
      conn =
        conn
        |> delete(Routes.image_path(conn, :delete, image.external_id))

      assert conn.status == 204
    end

    test "also delete attachment", %{image: image, conn: conn} do
      image
      |> Image.changeset_for_update(%{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
      })
      |> Repo.update()

      conn =
        conn
        |> delete(Routes.image_path(conn, :delete, image.external_id))

      assert conn.status == 204
    end

    test "not found", %{conn: conn} do
      conn =
        conn
        |> delete(Routes.image_path(conn, :delete, "aaa-bbb"))

      assert conn.status == 404
    end
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
