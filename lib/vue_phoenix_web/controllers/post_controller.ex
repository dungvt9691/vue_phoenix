defmodule VuePhoenixWeb.PostController do
  use VuePhoenixWeb, :controller

  alias VuePhoenix.Social

  def index(conn, params, _current_user) do
    results = Social.list_posts(params)

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

  def create(conn, _, current_user) do
    case Social.create_post(current_user, conn.params) do
      {:ok, post} ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: post,
          opts: [
            include: "user,images",
            fields: %{"user" => "email,first_name,last_name,avatar,full_name", "images" => "attachment"}
          ]
        )

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _current_user) do
    case Social.get_post!(id) do
      nil ->
        conn |> send_resp(404, "Not found")

      post ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: post,
          opts: [
            include: conn.query_params["include"],
            fields: conn.query_params["fields"]
          ]
        )
    end
  end

  def update(conn, %{"id" => id}, current_user) do
    case Social.get_post_by_user!(current_user, id) do
      nil ->
        conn |> send_resp(404, "Not found")

      post ->
        case Social.update_post(post, conn.params) do
          {:ok, post} ->
            conn
            |> put_status(:ok)
            |> render("show.json-api",
              data: post,
              opts: [
                include: "user,images",
                fields: %{"user" => "email,first_name,last_name,avatar,full_name", "images" => "attachment"}
              ]
            )

          {:error, changeset} ->
            conn
            |> put_status(422)
            |> put_view(VuePhoenixWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    case Social.get_post_by_user!(current_user, id) do
      nil ->
        conn |> send_resp(404, "Not found")

      post ->
        Social.delete_post(post)
        conn |> send_resp(204, "")
    end
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns[:signed_user]]
    apply(__MODULE__, action_name(conn), args)
  end
end
