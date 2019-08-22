defmodule VuePhoenix.Repo.Migrations.PostImagesDropTable do
  use Ecto.Migration

  def change do
    drop table("post_images")
  end
end
