defmodule VuePhoenix.Social do
  @moduledoc """
  The Social context.
  """
  import Ecto.Query, warn: false

  alias VuePhoenix.Repo
  alias VuePhoenix.Social.{Image, Post, PostImage}

  def list_posts(params \\ %{}) do
    Post
    |> preload([:user, :images])
    |> order_by(desc: :id)
    |> Repo.paginate(page: params["page"], page_size: params["limit"])
  end

  def get_post!(id) do
    Post
    |> preload([:user, :images])
    |> Repo.get_by(%{external_id: id})
  rescue
    _err -> nil
  end

  def get_post_by_user!(current_user, id) do
    Post
    |> preload([:user, :images])
    |> Repo.get_by(%{external_id: id, user_id: current_user.id})
  rescue
    _err -> nil
  end

  def create_post(current_user, attrs \\ %{}) do
    Repo.transaction(fn ->
      current_user
      |> Ecto.build_assoc(:posts)
      |> Post.changeset(attrs)
      |> Repo.insert()
      |> add_post_images(attrs)
      |> Repo.preload([:user, :images])
    end)
  end

  defp add_post_images({:error, changeset}, _attrs), do: Repo.rollback(changeset)

  defp add_post_images({:ok, post}, attrs) do
    Enum.each(attrs["image_ids"] || [], fn image_id ->
      case Repo.get_by(Image, %{external_id: image_id}) do
        nil ->
          post

        image ->
          post
          |> Ecto.build_assoc(:post_images)
          |> PostImage.changeset(%{image_id: image.id})
          |> Repo.insert()
          |> do_add_post_images
      end
    end)

    post
  end

  defp do_add_post_images({:ok, post_image}), do: post_image
  defp do_add_post_images({:error, changeset}), do: Repo.rollback(changeset)

  def update_post(%Post{} = post, attrs) do
    post
    |> Repo.preload([:user, :images])
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  alias VuePhoenix.Social.Image

  def list_images(current_user, params \\ %{}) do
    Image
    |> preload([:user])
    |> where([i], i.user_id == ^current_user.id)
    |> order_by(desc: :id)
    |> Repo.paginate(page: params["page"], page_size: params["limit"])
  end

  def get_image!(id) do
    Image
    |> preload([:user])
    |> Repo.get_by!(%{external_id: id})
  rescue
    _err -> nil
  end

  def get_image_by_user!(current_user, id) do
    Image
    |> preload([:user])
    |> Repo.get_by(%{external_id: id, user_id: current_user.id})
  rescue
    _err -> nil
  end

  def create_image(current_user, attrs \\ %{}) do
    image =
      current_user
      |> Ecto.build_assoc(:images)
      |> Image.changeset(attrs)

    case Repo.insert(image) do
      {:ok, image} ->
        image
        |> Repo.preload([:user])
        |> Image.changeset_for_update(attrs)
        |> Repo.update()

      error ->
        error
    end
  end

  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end
end
