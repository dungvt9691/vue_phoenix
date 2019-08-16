defmodule VuePhoenix.Repo.Migrations.UsersUpdateColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :reset_password_sent_at
      add :reset_password_expire_at, :naive_datetime
    end
  end
end
