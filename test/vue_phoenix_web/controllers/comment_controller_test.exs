defmodule VuePhoenixWeb.CommentControllerTest do
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
      post = insert(:post, user: token.user)
      insert_list(10, :comment, user: token.user, post: post)
      pagination_params = %{"page" => 1, "limit" => 2}
      include_params = %{"include" => "user", "fields" => %{}}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [
        pagination_params: pagination_params,
        include_params: include_params,
        conn: conn,
        post: post
      ]
    end

    test "post not found", %{conn: conn} do
      conn =
        conn
        |> get(Routes.post_comment_path(conn, :index, "aaa-bbb"))

      assert conn.status == 404
    end

    test "lists all entries on index", %{conn: conn, post: post} do
      conn =
        conn
        |> get(Routes.post_comment_path(conn, :index, post.external_id))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 10
    end

    test "lists entries by page and limit", %{
      conn: conn,
      post: post,
      pagination_params: pagination_params
    } do
      conn =
        conn
        |> get(Routes.post_comment_path(conn, :index, post.external_id, pagination_params))

      assert json_response(conn, 200)["data"]
      assert length(json_response(conn, 200)["data"]) == 2
    end

    test "lists entries with included", %{
      conn: conn,
      post: post,
      include_params: include_params
    } do
      conn =
        conn
        |> get(Routes.post_comment_path(conn, :index, post.external_id, include_params))

      assert json_response(conn, 200)["data"]

      assert Enum.map(json_response(conn, 200)["included"], fn include -> include["type"] end) ==
               ["user"]
    end

    test "lists entries with fields", %{
      conn: conn,
      post: post,
      include_params: include_params
    } do
      conn =
        conn
        |> get(
          Routes.post_comment_path(conn, :index, post.external_id, %{
            include_params
            | "fields" => %{"user" => "email"}
          })
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
      post = insert(:post, user: token.user)
      valid_attrs = %{"content" => "Content"}
      invalid_attrs = %{"content" => ""}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [conn: conn, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs, post: post]
    end

    test "valid attrs", %{conn: conn, post: post, valid_attrs: valid_attrs} do
      conn =
        conn
        |> post(Routes.post_comment_path(conn, :create, post.external_id), valid_attrs)

      assert json_response(conn, 200)
    end

    test "invalid attrs", %{conn: conn, post: post, invalid_attrs: invalid_attrs} do
      conn =
        conn
        |> post(Routes.post_comment_path(conn, :create, post.external_id), invalid_attrs)

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "content" => ["can't be blank"]
               }
             }
    end
  end

  describe "update" do
    setup %{token: token} do
      post = insert(:post, user: token.user)
      comment = insert(:comment, user: token.user, post: post)
      valid_attrs = %{"content" => "Content"}
      invalid_attrs = %{"content" => ""}

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [
        comment: comment,
        post: post,
        conn: conn,
        valid_attrs: valid_attrs,
        invalid_attrs: invalid_attrs
      ]
    end

    test "successfully", %{comment: comment, post: post, conn: conn, valid_attrs: valid_attrs} do
      conn =
        conn
        |> put(
          Routes.post_comment_path(conn, :update, post.external_id, comment.external_id),
          valid_attrs
        )

      assert json_response(conn, 200)["data"]
    end

    test "failed", %{comment: comment, post: post, conn: conn, invalid_attrs: invalid_attrs} do
      conn =
        conn
        |> put(
          Routes.post_comment_path(conn, :update, post.external_id, comment.external_id),
          invalid_attrs
        )

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "content" => ["can't be blank"]
               }
             }
    end

    test "not found", %{conn: conn, post: post, valid_attrs: valid_attrs} do
      conn =
        conn
        |> put(Routes.post_comment_path(conn, :update, post.external_id, "aaa-bbb"), valid_attrs)

      assert conn.status == 404
    end
  end

  describe "delete" do
    setup %{token: token} do
      post = insert(:post, user: token.user)
      comment = insert(:comment, user: token.user, post: post)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{token.code}")
        |> put_req_header("accept", "application/vnd.api+json")
        |> put_req_header("content-type", "application/vnd.api+json")

      [comment: comment, conn: conn, post: post]
    end

    test "successfully", %{comment: comment, post: post, conn: conn} do
      conn =
        conn
        |> delete(Routes.post_comment_path(conn, :delete, post.external_id, comment.external_id))

      assert conn.status == 204
    end

    test "not found", %{conn: conn, post: post} do
      conn =
        conn
        |> delete(Routes.post_comment_path(conn, :delete, post.external_id, "aaa-bbb"))

      assert conn.status == 404
    end
  end

  defp sign_up_user(_) do
    token = fixture(:sign_up)
    {:ok, token: token}
  end
end
