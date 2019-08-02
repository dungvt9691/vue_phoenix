defmodule VuePhoenixWeb.RegistrationsController do
  use VuePhoenixWeb, :controller
  alias VuePhoenix.{Repo, User}
  alias VuePhoenix.Services.{Authenticator}

  def create(conn, _params) do
    changeset = User.changeset(%User{}, conn.params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        token = Authenticator.generate_token(user)
        case Repo.insert(Ecto.build_assoc(user, :tokens, %{code: token})) do
          { :ok, token } ->
            conn
            |> put_status(:ok)
            |> render("show.json", token)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> put_view(VuePhoenixWeb.ChangesetView)
            |> render("error.json", changeset: changeset)
        end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(VuePhoenixWeb.ChangesetView)
        |> render("error.json", changeset: changeset)
    end
  end
end
