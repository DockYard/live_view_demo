defmodule LiveViewDemo.SqlLab.QueryExecuter do
  alias LiveViewDemo.Repo

  def handle_sql_petition(petition),
    do: Repo.query(petition)

  def format_result(%Postgrex.Result{columns: columns, rows: rows}),
    do: {columns, rows}

  def format_error(%Postgrex.Error{postgres: %{message: message}}),
    do: message

end
