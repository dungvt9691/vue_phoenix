defmodule VuePhoenixWeb.PostViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.PostView

  test "index.json-api" do
    posts = insert_list(10, :post)
    rendered_posts = PostView.render("index.json-api", data: posts)

    assert rendered_posts["data"]
  end

  test "show.json-api" do
    post = insert(:post)
    rendered_post = PostView.render("show.json-api", data: post)

    assert rendered_post["data"]["attributes"] == %{
             "content" => post.content,
             "inserted_at" => post.inserted_at,
             "updated_at" => post.updated_at
           }
  end
end
