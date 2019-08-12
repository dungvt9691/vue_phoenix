defmodule VuePhoenix.Repo.Migrations.CreatePostImages do
  use Ecto.Migration

  def change do
    create table(:post_images) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :image_id, references(:images, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:post_images, [:post_id, :image_id], unique: true)
  end
end
