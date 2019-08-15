defmodule VuePhoenixWeb.CommentController do
  use VuePhoenixWeb, :controller

  alias VuePhoenix.Social

  def index(conn, params, post, _current_user) do
    results = Social.list_comments(post, params)

    conn
    |> put_status(:ok)
    |> Scrivener.Headers.paginate(results)
    |> render("index.json-api",
      data: results.entries,
      opts: [
        include: conn.query_params["include"],
        fields: conn.query_params["fields"]
      ]
    )
  end

  def create(conn, _, post, current_user) do
    case Social.create_comment(current_user, post, conn.params) do
      {:ok, comment} ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: comment,
          opts: [
            include: "user",
            fields: %{"user" => "email,first_name,last_name,avatar"}
          ]
        )

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id}, _post, current_user) do
    case Social.get_comment_by_user!(current_user, id) do
      nil ->
        conn |> send_resp(404, "Not found")

      comment ->
        case Social.update_comment(comment, conn.params) do
          {:ok, comment} ->
            conn
            |> put_status(:ok)
            |> render("show.json-api",
              data: comment,
              opts: [
                include: "user",
                fields: %{"user" => "email,first_name,last_name,avatar"}
              ]
            )

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(VuePhoenixWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}, _post, current_user) do
    case Social.get_comment_by_user!(current_user, id) do
      nil ->
        conn |> send_resp(404, "Not found")

      comment ->
        Social.delete_comment(comment)
        conn |> send_resp(204, "")
    end
  end

  def action(conn, _) do
    case Social.get_post!(conn.params["post_id"]) do
      nil ->
        conn |> send_resp(404, "Not found")

      post ->
        args = [conn, conn.params, post, conn.assigns[:signed_user]]
        apply(__MODULE__, action_name(conn), args)
    end
  end
end
