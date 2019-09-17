defmodule LiveViewDemo.Queries.OrderQueries do
  import Ecto.Query

  alias LiveViewDemo.Repo
  alias LiveViewDemo.Schemas.Order

  def get_orders_status_count() do
    Order
    |> select([o], [o.status, count(o.id)])
    |> group_by(:status)
    |> Repo.all()
  end
end
