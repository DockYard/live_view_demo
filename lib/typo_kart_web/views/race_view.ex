defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  alias TypoKart.{
    Course,
    Game,
    GameMaster,
    Path,
    PathCharIndex,
    Player
  }

  @marker_scale "0.2"

  @spec course_transform(Game.t(), list(ViewChar.t()), integer()) :: binary()
  def course_transform(
        %Game{
          course: %Course{
            base_translate_x: base_translate_x,
            base_translate_y: base_translate_y,
            course_rotation_center_x: course_rotation_center_x,
            course_rotation_center_y: course_rotation_center_y
          }
        } = game,
        view_chars,
        player_index
      )
      when is_integer(player_index) do
    case length(view_chars) do
      0 ->
        "translate(#{base_translate_x},#{base_translate_y}) rotate(0, #{course_rotation_center_x}, #{
          course_rotation_center_y
        })"

      _ ->
        "translate(#{base_translate_x},#{base_translate_y}) rotate(#{
          course_rotation(game, view_chars, player_index)
        }, #{course_rotation_center_x}, #{course_rotation_center_y})"
    end
  end

  @spec marker_transform(Game.t(), list(ViewChar.t()), integer(), float(), float(), float()) ::
          binary()
  def marker_transform(
        %Game{
          course: %Course{
            marker_center_offset_x: marker_center_offset_x,
            marker_center_offset_y: marker_center_offset_y
          }
        } = game,
        view_chars,
        player_index,
        marker_rotation_offset,
        marker_translate_offset_x,
        marker_translate_offset_y
      )
      when is_list(view_chars) and is_integer(player_index) do
    case length(view_chars) do
      0 ->
        "scale(#{@marker_scale})"

      _ ->
        %{x: cur_char_x, y: cur_char_y, rotation: cur_char_rotation} =
          cur_view_char(game, view_chars, player_index)

        "rotate(#{cur_char_rotation + marker_rotation_offset}, #{cur_char_x}, #{cur_char_y}) translate(#{
          cur_char_x - marker_center_offset_x + marker_translate_offset_x
        }, #{cur_char_y - marker_center_offset_y + marker_translate_offset_y}) scale(#{
          @marker_scale
        })"
    end
  end

  @spec cur_char_index(Game.t(), integer()) :: PathCharIndex.t()
  def cur_char_index(%Game{} = game, player_index) when is_integer(player_index) do
    cur_path_char_index(game, player_index)
    |> Map.get(:char_index)
  end

  @spec course_rotation(Game.t(), list(ViewChar.t()), integer()) :: float()
  def course_rotation(_, [], _), do: 0

  def course_rotation(%Game{} = game, view_chars, player_index)
      when is_list(view_chars) and is_integer(player_index),
      do: -1 * (cur_view_char(game, view_chars, player_index) |> Map.get(:rotation))

  @spec text_path_extra_attrs(Game.t(), integer()) :: binary()
  def text_path_extra_attrs(%Game{course: %{paths: paths}}, path_index)
      when is_integer(path_index) do
    paths
    |> Enum.at(path_index)
    |> Map.get(:text_path_extra_attrs)
    |> Map.to_list()
    |> Enum.map(fn {key, val} -> "#{key}=#{val}" end)
    |> Enum.join(" ")
  end

  @spec path_class(Course.t(), integer()) :: binary()
  def path_class(%Course{paths: paths}, path_index) when is_integer(path_index) do
    classes = "course path-#{path_index}"

    with %Path{extra_attrs: extra_attrs} <- Enum.at(paths, path_index),
         extra_classes <- Map.get(extra_attrs, "class", "") do
      "#{classes} #{extra_classes}"
    else
      _ ->
        classes
    end
  end

  defdelegate text_segments(game, path_index, player_index), to: GameMaster

  @spec cur_path_char_index(Game.t(), integer()) :: PathCharIndex.t()
  def cur_path_char_index(%Game{players: players}, player_index) when is_integer(player_index) do
    %Player{cur_path_char_indices: cur_path_char_indices} = Enum.at(players, player_index)
    hd(cur_path_char_indices)
  end

  @spec cur_view_char(Game.t(), list(ViewChar.t()), integer()) :: ViewChar.t()
  def cur_view_char(%Game{} = game, view_chars, player_index)
      when is_list(view_chars) and is_integer(player_index) do
    %{path_index: path_index, char_index: char_index} = cur_path_char_index(game, player_index)

    view_chars
    |> Enum.at(path_index)
    |> Enum.at(char_index)
  end

  @spec marker_class(Game.t(), list(ViewChar.t()), integer()) :: binary()
  def marker_class(%Game{players: players}, view_chars, player_index) do
    ([
       "marker",
       "player-#{player_index}",
       Enum.at(players, player_index) |> Map.get(:color)
     ] ++ if(length(view_chars) == 0, do: ["hide"], else: []))
    |> Enum.join(" ")
  end
end
