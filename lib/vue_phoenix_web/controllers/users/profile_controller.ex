defmodule VuePhoenixWeb.Users.ProfileController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.Identify
  alias VuePhoenix.Services.Datetime

  def show(conn, _) do
    conn
    |> put_status(:ok)
    |> render("show.json", profile: conn.assigns[:signed_user])
  end

  def update(conn, _) do
    date = Datetime.parse_date(conn.params["birthday"])
    params = %{conn.params | "birthday" => date}

    case Identify.update(conn.assigns[:signed_user], params) do
      {:ok, profile} ->
        conn
        |> put_status(:ok)
        |> render("show.json", profile: profile)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
