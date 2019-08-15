defmodule VuePhoenixWeb.CommentView do
  use VuePhoenixWeb, :view

  alias VuePhoenix.Repo

  use JaSerializer.PhoenixView

  attributes([:content, :post_id, :inserted_at, :updated_at])

  has_one :user,
    serializer: VuePhoenixWeb.UserView,
    include: false,
    identifiers: :when_included

  def id(comment, _conn) do
    comment.external_id
  end

  def post_id(comment, _conn) do
    comment =
      comment
      |> Repo.preload([:post])

    comment.post.external_id
  end
end
