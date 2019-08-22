defmodule VuePhoenixWeb.PostControllerTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase

  import VuePhoenix.Factory
  alias VuePhoenix.Identify

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
      insert_list(10, :post, user: token.user)
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
        |> get(Routes.post_path(conn, :index))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 10
    end

    test "lists entries by page and limit", %{
      conn: conn,
      pagination_params: pagination_params
    } do
      conn =
        conn
        |> get(Routes.post_path(conn, :index, pagination_params))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 2
    end

    test "lists entries with included", %{
      conn: conn,
      include_params: include_params
    } do
      conn =
        conn
        |> get(Routes.post_path(conn, :index, include_params))

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
          Routes.post_path(conn, :index, %{include_params | "fields" => %{"user" => "email"}})
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
      images = insert_list(5, :image, user: token.user)
      valid_attrs = %{"content" => "Content", "image_ids" => []}
      invalid_attrs = %{"content" => ""}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [conn: conn, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs, images: images]
    end

    test "have not images", %{conn: conn, valid_attrs: valid_attrs} do
      conn =
        conn
        |> post(Routes.post_path(conn, :create), valid_attrs)

      assert json_response(conn, 200)
    end

    test "have images", %{conn: conn, valid_attrs: valid_attrs, images: images} do
      image_ids = Enum.map(images, fn image -> image.external_id end)

      conn =
        conn
        |> post(Routes.post_path(conn, :create), %{valid_attrs | "image_ids" => image_ids})

      images_data = json_response(conn, 200)["data"]["relationships"]["images"]["data"]
      assert image_ids == Enum.map(images_data, fn image -> image["id"] end)
    end

    test "invalid attrs", %{conn: conn, invalid_attrs: invalid_attrs} do
      conn =
        conn
        |> post(Routes.post_path(conn, :create), invalid_attrs)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "content" => ["can't be blank"]
               }
             }
    end
  end

  describe "show" do
    setup %{token: token} do
      post = insert(:post, user: token.user)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [post: post, conn: conn]
    end

    test "successfully", %{post: post, conn: conn} do
      conn =
        conn
        |> get(Routes.post_path(conn, :show, post.external_id))

      assert json_response(conn, 200)["data"]
    end

    test "not found", %{conn: conn} do
      conn =
        conn
        |> get(Routes.post_path(conn, :show, "aaa-bbb"))

      assert conn.status == 404
    end
  end

  describe "update" do
    setup %{token: token} do
      post = insert(:post, user: token.user)
      valid_attrs = %{"content" => "Content"}
      invalid_attrs = %{"content" => ""}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [post: post, conn: conn, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "successfully", %{post: post, conn: conn, valid_attrs: valid_attrs} do
      conn =
        conn
        |> put(Routes.post_path(conn, :update, post.external_id), valid_attrs)

      assert json_response(conn, 200)["data"]
    end

    test "failed", %{post: post, conn: conn, invalid_attrs: invalid_attrs} do
      conn =
        conn
        |> put(Routes.post_path(conn, :update, post.external_id), invalid_attrs)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "content" => ["can't be blank"]
               }
             }
    end

    test "not found", %{conn: conn, valid_attrs: valid_attrs} do
      conn =
        conn
        |> put(Routes.post_path(conn, :update, "aaa-bbb"), valid_attrs)

      assert conn.status == 404
    end
  end

  describe "delete" do
    setup %{token: token} do
      post = insert(:post, user: token.user)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [post: post, conn: conn]
    end

    test "successfully", %{post: post, conn: conn} do
      conn =
        conn
        |> delete(Routes.post_path(conn, :delete, post.external_id))

      assert conn.status == 204
    end

    test "not found", %{conn: conn} do
      conn =
        conn
        |> delete(Routes.post_path(conn, :delete, "aaa-bbb"))

      assert conn.status == 404
    end
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
