defmodule VuePhoenix.Services.Images do
  @moduledoc false

  import Ecto.Query
  alias VuePhoenix.Repo
  alias VuePhoenix.Social
  alias VuePhoenix.Social.Image

  def siblings(image, post_uuid, user) do
    case Social.get_post!(post_uuid) do
      nil ->
        user =
          user
          |> Repo.preload(:images)

        if length(user.images) > 1 do
          %{
            "next" => next_sibling(image, nil, asc: :id),
            "prev" => prev_sibling(image, nil, desc: :id)
          }
        else
          nil
        end

      post ->
        if length(post.images) > 1 do
          %{
            "next" => next_sibling(image, post.id, asc: :id),
            "prev" => prev_sibling(image, post.id, desc: :id)
          }
        else
          nil
        end
    end
  end

  defp next_sibling(image, post_id, order_by) do
    query =
      case post_id do
        nil ->
          from i in Image,
            where: i.id > ^image.id and i.user_id == ^image.user_id,
            order_by: ^order_by,
            limit: 1

        post_id ->
          from i in Image,
            where: i.id > ^image.id and i.user_id == ^image.user_id and i.post_id == ^post_id,
            order_by: ^order_by,
            limit: 1
      end

    case Repo.one(query) do
      nil ->
        prev_sibling(image, post_id, asc: :id)

      image ->
        image =
          image
          |> Repo.preload(:post)

        %{
          "id" => image.external_id,
          "post_id" => image.post.external_id
        }
    end
  end

  defp prev_sibling(image, post_id, order_by) do
    query =
      case post_id do
        nil ->
          from i in Image,
            where: i.id < ^image.id and i.user_id == ^image.user_id,
            order_by: ^order_by,
            limit: 1

        post_id ->
          from i in Image,
            where: i.id < ^image.id and i.user_id == ^image.user_id and i.post_id == ^post_id,
            order_by: ^order_by,
            limit: 1
      end

    case Repo.one(query) do
      nil ->
        next_sibling(image, post_id, desc: :id)

      image ->
        image =
          image
          |> Repo.preload(:post)

        %{
          "id" => image.external_id,
          "post_id" => image.post.external_id
        }
    end
  end
end
