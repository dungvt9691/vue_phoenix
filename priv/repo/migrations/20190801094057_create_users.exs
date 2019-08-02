defmodule VuePhoenix.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :encrypted_password, :string
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
