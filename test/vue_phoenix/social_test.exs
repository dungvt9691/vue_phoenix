defmodule VuePhoenix.SocialTest do
  @moduledoc false
  use VuePhoenix.DataCase

  import VuePhoenix.Factory
  alias VuePhoenix.{Repo, Social}
  alias VuePhoenix.Social.{Comment, Image, Post}

  describe "list_posts" do
    setup do
      insert_list(10, :post)

      posts =
        Post
        |> preload([:user, :images])
        |> order_by(desc: :id)
        |> Repo.all()

      pagination_params = %{"page" => 1, "limit" => 2}
      [posts: posts, pagination_params: pagination_params]
    end

    test "all", %{posts: posts} do
      assert posts == Social.list_posts().entries
    end

    test "with page and limit params", %{posts: posts, pagination_params: pagination_params} do
      pagination = %{
        page_number: 1,
        page_size: 2,
        total_entries: 10,
        total_pages: 5
      }

      assert pagination.page_number == Social.list_posts(pagination_params).page_number
      assert pagination.page_size == Social.list_posts(pagination_params).page_size
      assert pagination.total_entries == Social.list_posts(pagination_params).total_entries
      assert pagination.total_pages == Social.list_posts(pagination_params).total_pages
      assert Enum.take(posts, 2) == Social.list_posts(pagination_params).entries
    end
  end

  describe "get_post!" do
    setup do
      post = insert(:post)

      post =
        Post
        |> preload([:user, :images])
        |> Repo.get(post.id)

      [post: post]
    end

    test "existed", %{post: post} do
      assert post == Social.get_post!(post.external_id)
    end

    test "not existed" do
      assert nil == Social.get_post!("aaa-bbb")
    end
  end

  describe "get_post_by_user!" do
    setup do
      user = insert(:user)
      post = insert(:post, user: user)

      post =
        Post
        |> preload([:user, :images])
        |> Repo.get(post.id)

      [post: post, user: user]
    end

    test "existed", %{post: post, user: user} do
      assert post == Social.get_post_by_user!(user, post.external_id)
    end

    test "not existed", %{user: user} do
      assert nil == Social.get_post_by_user!(user, "aaa-bbb")
    end
  end

  describe "create_post" do
    setup do
      user = insert(:user)
      images = insert_list(5, :image)
      valid_attrs = %{"content" => "Content", "image_ids" => []}
      invalid_attrs = %{"content" => ""}
      [user: user, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs, images: images]
    end

    test "invalid attrs", %{user: user, invalid_attrs: invalid_attrs} do
      assert {:error, _} = Social.create_post(user, invalid_attrs)
    end

    test "have not images", %{user: user, valid_attrs: valid_attrs} do
      assert {:ok, _} = Social.create_post(user, valid_attrs)
    end

    test "have images", %{user: user, images: images, valid_attrs: valid_attrs} do
      image_ids = Enum.map(images, fn image -> image.external_id end)
      {:ok, post} = Social.create_post(user, %{valid_attrs | "image_ids" => image_ids})
      assert image_ids == Enum.map(post.images, fn image -> image.external_id end)
    end

    test "there is a image not existed", %{user: user, images: images, valid_attrs: valid_attrs} do
      image_ids = Enum.map(images, fn image -> image.external_id end)
      added_image_ids = image_ids

      {:ok, post} =
        Social.create_post(user, %{valid_attrs | "image_ids" => ["aaa-bbb" | added_image_ids]})

      assert image_ids == Enum.map(post.images, fn image -> image.external_id end)
    end
  end

  describe "update_post" do
    setup do
      post = insert(:post)
      valid_attrs = %{"content" => "Updated"}
      invalid_attrs = %{"content" => ""}
      [post: post, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attrs", %{post: post, valid_attrs: valid_attrs} do
      assert {:ok, _} = Social.update_post(post, valid_attrs)
    end

    test "invalid attrs", %{post: post, invalid_attrs: invalid_attrs} do
      assert {:error, _} = Social.update_post(post, invalid_attrs)
    end
  end

  describe "delete_post" do
    setup do
      post = insert(:post)
      [post: post]
    end

    test "successfully", %{post: post} do
      assert {:ok, _} = Social.delete_post(post)
    end
  end

  describe "list_images" do
    setup do
      user = insert(:user)
      post = insert(:post, user: user)
      insert_list(10, :image, user: user, post: post)

      images =
        Image
        |> preload([:user, :post])
        |> order_by(desc: :id)
        |> Repo.all()

      pagination_params = %{"page" => 1, "limit" => 2}
      [user: user, images: images, pagination_params: pagination_params]
    end

    test "all", %{user: user, images: images} do
      assert images == Social.list_images(user).entries
    end

    test "with page and limit params", %{
      user: user,
      images: images,
      pagination_params: pagination_params
    } do
      pagination = %{
        page_number: 1,
        page_size: 2,
        total_entries: 10,
        total_pages: 5
      }

      assert pagination.page_number == Social.list_images(user, pagination_params).page_number
      assert pagination.page_size == Social.list_images(user, pagination_params).page_size
      assert pagination.total_entries == Social.list_images(user, pagination_params).total_entries
      assert pagination.total_pages == Social.list_images(user, pagination_params).total_pages
      assert Enum.take(images, 2) == Social.list_images(user, pagination_params).entries
    end
  end

  describe "get_image!" do
    setup do
      image = insert(:image)

      image =
        Image
        |> preload([:user, :post])
        |> Repo.get(image.id)

      [image: image]
    end

    test "existed", %{image: image} do
      assert image == Social.get_image!(image.external_id)
    end

    test "not existed" do
      assert nil == Social.get_image!("aaa-bbb")
    end
  end

  describe "get_image_by_user!" do
    setup do
      user = insert(:user)
      image = insert(:image, user: user)

      image =
        Image
        |> preload([:user])
        |> Repo.get(image.id)

      [image: image, user: user]
    end

    test "existed", %{image: image, user: user} do
      assert image == Social.get_image_by_user!(user, image.external_id)
    end

    test "not existed", %{user: user} do
      assert nil == Social.get_image_by_user!(user, "aaa-bbb")
    end
  end

  describe "create_image" do
    setup do
      user = insert(:user)

      valid_attrs = %{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
      }

      invalid_attrs = %{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.bmp", filename: "sample.bmp"}
      }

      [user: user, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attrs", %{user: user, valid_attrs: valid_attrs} do
      assert {:ok, _} = Social.create_image(user, valid_attrs)
    end

    test "invalid attrs", %{user: user, invalid_attrs: invalid_attrs} do
      ExUnit.CaptureLog.capture_log(fn ->
        assert {:error, _} = Social.create_image(user, invalid_attrs)
      end)
    end
  end

  describe "delete_image" do
    setup do
      image = insert(:image)
      [image: image]
    end

    test "successfully", %{image: image} do
      assert {:ok, _} = Social.delete_image(image)
    end

    test "also delete attachment", %{image: image} do
      image
      |> Image.changeset_for_update(%{
        "attachment" => %Plug.Upload{path: "test/fixtures/sample.png", filename: "sample.png"}
      })
      |> Repo.update()

      assert {:ok, _} = Social.delete_image(image)
    end
  end

  describe "list_comments" do
    setup do
      user = insert(:user)
      post = insert(:post, user: user)
      insert_list(10, :comment, post: post, user: user)

      comments =
        Comment
        |> preload([:user])
        |> order_by(desc: :id)
        |> Repo.all()

      pagination_params = %{"page" => 1, "limit" => 2}
      [post: post, comments: comments, pagination_params: pagination_params]
    end

    test "all", %{post: post, comments: comments} do
      assert comments == Social.list_comments(post).entries
    end

    test "with page and limit params", %{
      post: post,
      comments: comments,
      pagination_params: pagination_params
    } do
      pagination = %{
        page_number: 1,
        page_size: 2,
        total_entries: 10,
        total_pages: 5
      }

      assert pagination.page_number == Social.list_comments(post, pagination_params).page_number
      assert pagination.page_size == Social.list_comments(post, pagination_params).page_size

      assert pagination.total_entries ==
               Social.list_comments(post, pagination_params).total_entries

      assert pagination.total_pages == Social.list_comments(post, pagination_params).total_pages
      assert Enum.take(comments, 2) == Social.list_comments(post, pagination_params).entries
    end
  end

  describe "get_comment_by_user!" do
    setup do
      user = insert(:user)
      post = insert(:post, user: user)
      comment = insert(:comment, user: user, post: post)

      comment =
        Comment
        |> preload([:user])
        |> Repo.get(comment.id)

      [comment: comment, user: user]
    end

    test "existed", %{comment: comment, user: user} do
      assert comment == Social.get_comment_by_user!(user, comment.external_id)
    end

    test "not existed", %{user: user} do
      assert nil == Social.get_comment_by_user!(user, "aaa-bbb")
    end
  end

  describe "create_comment" do
    setup do
      user = insert(:user)
      post = insert(:post, user: user)

      valid_attrs = %{
        "content" => "Content"
      }

      invalid_attrs = %{
        "content" => ""
      }

      [user: user, post: post, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attrs", %{user: user, post: post, valid_attrs: valid_attrs} do
      assert {:ok, _} = Social.create_comment(user, post, valid_attrs)
    end

    test "invalid attrs", %{user: user, post: post, invalid_attrs: invalid_attrs} do
      assert {:error, _} = Social.create_comment(user, post, invalid_attrs)
    end
  end

  describe "update_comment" do
    setup do
      comment = insert(:comment)
      valid_attrs = %{"content" => "Updated"}
      invalid_attrs = %{"content" => ""}
      [comment: comment, valid_attrs: valid_attrs, invalid_attrs: invalid_attrs]
    end

    test "valid attrs", %{comment: comment, valid_attrs: valid_attrs} do
      assert {:ok, _} = Social.update_comment(comment, valid_attrs)
    end

    test "invalid attrs", %{comment: comment, invalid_attrs: invalid_attrs} do
      assert {:error, _} = Social.update_comment(comment, invalid_attrs)
    end
  end

  describe "delete_comment" do
    setup do
      comment = insert(:comment)
      [comment: comment]
    end

    test "successfully", %{comment: comment} do
      assert {:ok, _} = Social.delete_comment(comment)
    end
  end
end
