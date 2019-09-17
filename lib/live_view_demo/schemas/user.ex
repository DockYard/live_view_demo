defmodule LiveViewDemo.Schemas.User do
  use Ecto.Schema

  alias LiveViewDemo.Schema.Order

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password_hash, :string)

    has_many(:order, Order, foreign_key: :user_id)

    timestamps()
  end
end
