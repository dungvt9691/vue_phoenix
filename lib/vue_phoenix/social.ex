defmodule VuePhoenix.Social do
  @moduledoc """
  The Social context.
  """
  import Ecto.Query, warn: false

  alias VuePhoenix.Repo
  alias VuePhoenix.Social
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
      case Social.get_image!(image_id) do
        nil ->
          post

        image ->
          post
          |> Ecto.build_assoc(:post_images)
          |> PostImage.changeset(%{image_id: image.id})
          |> Repo.insert()
      end
    end)

    post
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Repo.preload([:user, :images])
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

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
    end
  end

  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  alias VuePhoenix.Social.Comment

  def list_comments(post, params \\ %{}) do
    Comment
    |> preload([:user])
    |> where([i], i.post_id == ^post.id)
    |> order_by(desc: :id)
    |> Repo.paginate(page: params["page"], page_size: params["limit"])
  end

  def get_comment_by_user!(current_user, id) do
    Comment
    |> preload([:user])
    |> Repo.get_by(%{external_id: id, user_id: current_user.id})
  rescue
    _err -> nil
  end

  def create_comment(current_user, post, attrs \\ %{}) do
    current_user
    |> Ecto.build_assoc(:comments)
    |> Repo.preload([:user])
    |> Comment.changeset(Map.put(attrs, "post_id", post.id))
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Repo.preload([:user])
    |> Comment.changeset_for_update(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end
end
