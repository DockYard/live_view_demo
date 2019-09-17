defmodule LiveViewDemo.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:first_name, :string, null: false)
      add(:last_name, :string, null: false)
      add(:email, :string, null: false)
      add(:password_hash, :string)

      timestamps()
    end

    create(unique_index(:users, [:email], name: :sutro_user_email_unique_index))
    end
end
