defmodule VuePhoenix.Repo.Migrations.ImagesAddColumnPostId do
  use Ecto.Migration

  def change do
    alter table(:images) do
      add :post_id, references(:posts, on_delete: :nilify_all), null: true
    end
  end
end
