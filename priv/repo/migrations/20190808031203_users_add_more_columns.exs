defmodule VuePhoenix.Repo.Migrations.UsersAddMoreColumns do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :first_name, :string
      add :last_name, :string
      add :avatar, :string
      add :birthday, :utc_datetime
    end
  end
end
