defmodule LiveViewDemo.Queries.UserQueries do
  import Ecto.Query

  alias LiveViewDemo.Repo
  alias LiveViewDemo.Schemas.User

  def get_newest_users(limit \\ 10) do
    User
    |> select([:first_name, :last_name, :email, :inserted_at])
    |> limit(^limit)
    |> order_by([desc: :inserted_at])
    |> Repo.all()
  end

  # def get_users_w_most_orders() do
  #
  # end
end
