# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LiveViewDemo.Repo.insert!(%LiveViewDemo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias LiveViewDemo.Repo
alias LiveViewDemo.Schemas.{User, Order}

time_minus_minutes = fn minutes -> NaiveDateTime.utc_now() |> NaiveDateTime.add(minutes * 60, :second) |> NaiveDateTime.truncate(:second) end
time_minus_days = fn days -> NaiveDateTime.utc_now() |> NaiveDateTime.add(days * 60 * 60 * 24, :second) |> NaiveDateTime.truncate(:second) end

users = [
  %{first_name: "Robert", last_name: "Fripp", email: "robert@kingcrimson.com", password_hash: "f", inserted_at: time_minus_minutes.(-6), updated_at: time_minus_minutes.(-6)},
  %{first_name: "Trent", last_name: "Reznor", email: "trent@nin.com", password_hash: "e", inserted_at: time_minus_minutes.(-5), updated_at: time_minus_minutes.(-5)},
  %{first_name: "George", last_name: "Harrison", email: "george@beatles.com", password_hash: "d", inserted_at: time_minus_minutes.(-4), updated_at: time_minus_minutes.(-4)},
  %{first_name: "Mick", last_name: "Jagger", email: "mick@rollingstones.com", password_hash: "c", inserted_at: time_minus_minutes.(-3), updated_at: time_minus_minutes.(-3)},
  %{first_name: "David", last_name: "Bowie", email: "david@bowie.com", password_hash: "b", inserted_at: time_minus_minutes.(-2), updated_at: time_minus_minutes.(-2)},
  %{first_name: "Lou", last_name: "Reed", email: "lou@velvetunderground.com", password_hash: "a", inserted_at: time_minus_minutes.(-1), updated_at: time_minus_minutes.(-1)},
]

Repo.insert_all(User, users)

orders = [
  %{items_amount: 199.12, shipping_amount: 87.57, total_amount: 286.69, status: "pending", user_id: 1, inserted_at: time_minus_days.(-1), updated_at: time_minus_days.(-1)},
  %{items_amount: 451.03, shipping_amount: 97.09, total_amount: 548.12, status: "completed", user_id: 1, inserted_at: time_minus_days.(-2), updated_at: time_minus_days.(-2)},
  %{items_amount: 230.25, shipping_amount: 18.09, total_amount: 248.34, status: "failed", user_id: 2, inserted_at: time_minus_days.(-3), updated_at: time_minus_days.(-3)},
  %{items_amount: 2546.36, shipping_amount: 78.50, total_amount: 2624.86, status: "completed", user_id: 2, inserted_at: time_minus_days.(-7), updated_at: time_minus_days.(-7)},
  %{items_amount: 46.10, shipping_amount: 24.03, total_amount: 70.13, status: "completed", user_id: 3, inserted_at: time_minus_days.(-7), updated_at: time_minus_days.(-7)},
  %{items_amount: 345.09, shipping_amount: 24.53, total_amount: 369.62, status: "completed", user_id: 2, inserted_at: time_minus_days.(-4), updated_at: time_minus_days.(-4)},
  %{items_amount: 363.46, shipping_amount: 20.34, total_amount: 383.80, status: "pending", user_id: 3, inserted_at: time_minus_days.(-5), updated_at: time_minus_days.(-5)},
  %{items_amount: 932.08, shipping_amount: 190.23, total_amount: 1122.31, status: "failed", user_id: 1, inserted_at: time_minus_days.(-6), updated_at: time_minus_days.(-6)},
  %{items_amount: 258.09, shipping_amount: 48.08, total_amount: 306.17, status: "failed", user_id: 3, inserted_at: time_minus_days.(-0), updated_at: time_minus_days.(-0)},
  %{items_amount: 768.78, shipping_amount: 98.92, total_amount: 867.70, status: "completed", user_id: 3, inserted_at: time_minus_days.(-1), updated_at: time_minus_days.(-1)},
  %{items_amount: 3423.92, shipping_amount: 87.24, total_amount: 3511.16, status: "completed", user_id: 4, inserted_at: time_minus_days.(-1), updated_at: time_minus_days.(-1)},
  %{items_amount: 7.92, shipping_amount: 98.14, total_amount: 106.06, status: "pending", user_id: 1, inserted_at: time_minus_days.(-3), updated_at: time_minus_days.(-3)},
  %{items_amount: 67.32, shipping_amount: 98.45, total_amount: 165.77, status: "completed", user_id: 5, inserted_at: time_minus_days.(-2), updated_at: time_minus_days.(-2)},
  %{items_amount: 55.22, shipping_amount: 80.35, total_amount: 135.57, status: "completed", user_id: 1, inserted_at: time_minus_days.(-2), updated_at: time_minus_days.(-2)},
  %{items_amount: 1093.88, shipping_amount: 89.23, total_amount: 1183.11, status: "failed", user_id: 2, inserted_at: time_minus_days.(-4), updated_at: time_minus_days.(-4)},
  %{items_amount: 675.99, shipping_amount: 87.67, total_amount: 763.66, status: "pending", user_id: 3, inserted_at: time_minus_days.(-4), updated_at: time_minus_days.(-4)},
]

Repo.insert_all(Order, orders)
