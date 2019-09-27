defmodule LiveViewDemo.Queries.UserQueries do
  import Ecto.Query

  alias LiveViewDemo.Repo
  alias LiveViewDemo.Schemas.{User, Order}

  def get_newest_users(limit \\ 10) do
    User
    |> select([:first_name, :last_name, :email, :inserted_at])
    |> limit(^limit)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
  end

  def get_users_w_most_orders() do
    Order
    |> select([o, u], [sum(o.items_amount), u.first_name])
    |> join(:inner, [o], u in User, on: o.user_id == u.id)
    |> group_by([o, u], u.id)
    |> order_by([o, u], [desc: sum(o.items_amount)])
    |> Repo.all()
  end
end
