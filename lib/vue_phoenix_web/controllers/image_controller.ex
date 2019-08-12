defmodule VuePhoenixWeb.ImageController do
  use VuePhoenixWeb, :controller

  alias VuePhoenix.Social

  def index(conn, params) do
    results = Social.list_images(conn.assigns[:signed_user], params)

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

  def create(conn, _) do
    case Social.create_image(conn.assigns[:signed_user], conn.params) do
      {:ok, image} ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: image,
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

  def show(conn, %{"id" => id}) do
    case Social.get_image!(id) do
      nil ->
        conn |> send_resp(404, "Not found")

      image ->
        conn
        |> put_status(:ok)
        |> render("show.json-api",
          data: image,
          opts: [
            include: conn.query_params["include"],
            fields: conn.query_params["fields"]
          ]
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    case Social.get_image_by_user!(conn.assigns[:signed_user], id) do
      nil ->
        conn |> send_resp(404, "Not found")

      image ->
        if image.attachment do
          VuePhoenix.Image.delete({image.attachment, image})
        end

        Social.delete_image(image)
        conn |> send_resp(204, "")
    end
  end
end
