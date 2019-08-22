defmodule VuePhoenixWeb.Users.PostController do
  use VuePhoenixWeb, :controller

  alias VuePhoenix.Social

  def index(conn, params, current_user) do
    results = Social.list_posts_by_user!(current_user, params)

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

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns[:signed_user]]
    apply(__MODULE__, action_name(conn), args)
  end
end
