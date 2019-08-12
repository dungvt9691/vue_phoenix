defmodule VuePhoenixWeb.ImageViewTest do
  @moduledoc false
  use VuePhoenixWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import VuePhoenix.Factory
  alias VuePhoenixWeb.ImageView

  test "index.json-api" do
    images = insert_list(10, :image)
    rendered_images = ImageView.render("index.json-api", data: images)

    assert rendered_images["data"]
  end

  test "show.json-api" do
    image = insert(:image)
    rendered_image = ImageView.render("show.json-api", data: image)

    assert rendered_image["data"]["attributes"] == %{
             "attachment" => VuePhoenix.Image.urls({image.attachment, image}),
             "inserted_at" => image.inserted_at,
             "updated_at" => image.updated_at
           }
  end
end
