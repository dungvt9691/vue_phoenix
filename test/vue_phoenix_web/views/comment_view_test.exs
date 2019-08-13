defmodule VuePhoenixWeb.CommentViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory

  alias VuePhoenix.Repo
  alias VuePhoenixWeb.CommentView

  setup do
    user = insert(:user)
    post = insert(:post, user: user)
    comment = insert(:comment, user: user, post: post)
    comments = insert_list(10, :comment, user: user, post: post)

    [comments: comments, comment: comment]
  end

  test "index.json-api", %{comments: comments} do
    rendered_comments = CommentView.render("index.json-api", data: comments)

    assert rendered_comments["data"]
  end

  test "show.json-api", %{comment: comment} do
    comment =
      comment
      |> Repo.preload([:post])

    rendered_comment = CommentView.render("show.json-api", data: comment)

    assert rendered_comment["data"]["attributes"] == %{
             "content" => comment.content,
             "inserted_at" => comment.inserted_at,
             "updated_at" => comment.updated_at,
             "post_id" => comment.post.external_id
           }
  end
end
