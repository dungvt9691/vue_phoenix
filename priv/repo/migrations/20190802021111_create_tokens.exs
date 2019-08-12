defmodule VuePhoenix.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :code, :text, null: false
      add :revoked, :boolean, default: false, null: false
      add :revoked_at, :utc_datetime
      timestamps()
    end

    create unique_index(:tokens, [:code])
    create index(:tokens, [:user_id])
  end
end
