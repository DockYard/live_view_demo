defmodule TypoKart.Courses do
  @course_dir "priv/static/courses"
  alias TypoKart.{
    Course
  }

  @spec load(binary()) :: {:ok, Course.t} | {:error, binary()}
  def load(name) when is_binary(name) do
    with {:ok, data} <- Path.join(File.cwd!(), "#{@course_dir}/#{name}.yml") |> YamlElixir.read_from_file(),
      paths <- paths(Map.get(data, "paths"), Map.get(data, "chars")) do
      {:ok, %Course{
        paths: paths,
        initial_rotation: Map.get(data, "initial_rotation"),
        base_translate_x: Map.get(data, "base_translate_x"),
        base_translate_y: Map.get(data, "base_translate_y"),
        view_box: Map.get(data, "view_box"),
        marker_center_offset_x: Map.get(data, "marker_center_offset_x"),
        marker_center_offset_y: Map.get(data, "marker_center_offset_y")
      }}
    else
      bad ->
        {:error, bad}
    end
  end

  defp paths(path_data_list, chars_list) when is_list(path_data_list) and is_list(chars_list) do
    Enum.with_index(path_data_list)
    |> Enum.map(fn {d, index} -> %TypoKart.Path{
      d: d,
      chars: Enum.at(chars_list, index) |> String.to_charlist()
    } end)
  end
end
