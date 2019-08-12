defmodule VuePhoenix.Repo.Migrations.UsersAddMoreColumns do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :external_id, :uuid, null: false
      add :first_name, :string
      add :last_name, :string
      add :avatar, :string
      add :birthday, :naive_datetime
      modify :reset_password_sent_at, :naive_datetime
    end
  end
end
