defmodule LiveViewDemo.Queries.CommonQueries do
  alias LiveViewDemo.Repo

  def get_public_tables() do
    """
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema='public'
    AND table_type='BASE TABLE';
    """
    |> Repo.query()
    |> format_public_tables_result()
  end

  defp format_public_tables_result({:error, _}), do: []

  defp format_public_tables_result({:ok, %{rows: rows}}) do
    rows
    |> Enum.filter(fn [name] -> name != "schema_migrations" end)
    |> List.flatten()
  end

  def get_table_columns(table) do
    """
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema='public'
    AND table_name='#{table}';
    """
    |> Repo.query()
    |> format_columns_result()
  end

  defp format_columns_result({:error, _}), do: []
  defp format_columns_result({:ok, %{rows: rows}}), do: List.flatten(rows)

end
