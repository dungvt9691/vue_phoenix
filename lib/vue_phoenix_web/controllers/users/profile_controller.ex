defmodule VuePhoenixWeb.Users.ProfileController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.{Identify, Repo}
  alias VuePhoenix.Services.Datetime

  def show(conn, _) do
    user =
      conn.assigns[:signed_user]
      |> Repo.preload([:tokens, :posts, :images])

    conn
    |> put_status(:ok)
    |> render("show.json-api",
      data: user,
      opts: [
        include: conn.query_params["include"],
        fields: conn.query_params["fields"]
      ]
    )
  end

  def update(conn, _) do
    date = Datetime.parse_date(conn.params["birthday"])
    params = %{conn.params | "birthday" => date}

    case Identify.update(conn.assigns[:signed_user], params) do
      {:ok, profile} ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: profile,
          opts: [
            include: conn.query_params["include"],
            fields: conn.query_params["fields"]
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
