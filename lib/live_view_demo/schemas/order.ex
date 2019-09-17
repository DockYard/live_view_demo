defmodule LiveViewDemo.Schemas.Order do
  use Ecto.Schema

  alias LiveViewDemo.Schema.User

  schema "orders" do
    field(:items_amount, :float)
    field(:shipping_amount, :float)
    field(:total_amount, :float)
    field(:status, :string)

    belongs_to(:user, User)

    timestamps()
  end
end
