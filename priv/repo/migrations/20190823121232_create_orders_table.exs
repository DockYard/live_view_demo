defmodule LiveViewDemo.Repo.Migrations.CreateOrdersTable do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add(:items_amount, :float, null: false)
      add(:shipping_amount, :float, null: false)
      add(:total_amount, :float, null: false)
      add(:status, :string, null: false)

      add(:user_id, references(:users, on_delete: :nothing))

      timestamps()
    end
  end
end
