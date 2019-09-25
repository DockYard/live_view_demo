defmodule LiveViewDemo.SqlLab.CsvDownload do

  def format_csv_for_download(columns, rows) do
    prefix = "data:text/csv;charset=utf-8,"

    first_row = Enum.join(columns, ",")

    content =
      rows
      |> Enum.map(&Enum.join(&1, ","))
      |> Enum.join("\n")

    prefix <> first_row <> "\n" <> content
  end

end
