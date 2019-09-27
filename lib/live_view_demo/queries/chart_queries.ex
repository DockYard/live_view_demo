defmodule LiveViewDemo.Queries.ChartQueries do
  import Ecto.Query

  alias LiveViewDemo.Repo

  def get_count_for_pie_chart(table, column) do
    """
      SELECT "#{column}", count("#{column}")
      FROM #{table}
      GROUP BY "#{column}"
    """
    |> Repo.query()
    |> get_rows_from_explicit_query()
  end

  def get_rows_from_explicit_query({:error, %{postgres: %{message: message}}}), do: {:error, message}
  def get_rows_from_explicit_query({:ok, %{rows: rows}}), do: {:ok, rows}

end
