defmodule VuePhoenix.Repo.Migrations.TokensAddExternalId do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :external_id, :uuid, null: false
      modify :revoked_at, :naive_datetime
    end
  end
end
