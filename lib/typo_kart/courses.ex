defmodule TypoKart.Courses do
  @course_dir "assets/static/courses"
  alias TypoKart.{
    Course,
    PathCharIndex
  }

  @spec load(binary()) :: {:ok, Course.t} | {:error, binary()}
  def load(name) when is_binary(name) do
    with {:ok, data} <- Path.join(File.cwd!(), "#{@course_dir}/#{name}.yml") |> YamlElixir.read_from_file(),
      paths <- paths(data),
      path_connections <- path_connections(data) do
      {:ok, %Course{
        paths: paths,
        path_connections: path_connections,
        initial_rotation: Map.get(data, "initial_rotation"),
        base_translate_x: Map.get(data, "base_translate_x"),
        base_translate_y: Map.get(data, "base_translate_y"),
        view_box: Map.get(data, "view_box"),
        marker_center_offset_x: Map.get(data, "marker_center_offset_x"),
        marker_center_offset_y: Map.get(data, "marker_center_offset_y"),
        course_rotation_center_x: Map.get(data, "course_rotation_center_x"),
        course_rotation_center_y: Map.get(data, "course_rotation_center_y")
      }}
    else
      bad ->
        {:error, bad}
    end
  end

  defp paths(%{"paths" => paths, "text_paths" => text_paths}) do
    Enum.with_index(paths)
    |> Enum.map(fn {path, index} -> %TypoKart.Path{
      d: Map.get(path, "d") |> String.trim(),
      extra_attrs: Map.get(path, "extra_attrs", %{}),
      chars: Enum.at(text_paths, index) |> Map.get("chars") |> String.trim() |> String.to_charlist(),
      text_path_extra_attrs: Enum.at(text_paths, index) |> Map.get("extra_attrs", %{})
    } end)
  end

  defp path_connections(%{"path_connections" => path_connections}) do
    path_connections
    |> Enum.map(&({
      struct(PathCharIndex, path_index: Enum.at(&1, 0) |> Map.get("path_index"), char_index: Enum.at(&1, 0) |> Map.get("char_index")),
      struct(PathCharIndex, path_index: Enum.at(&1, 1) |> Map.get("path_index"), char_index: Enum.at(&1, 1) |> Map.get("char_index"))
    }))
  end
end
