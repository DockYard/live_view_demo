defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  alias TypoKart.{
    Course,
    Game,
    Player
  }

  def map_transform(
        %Course{base_translate_x: base_translate_x, base_translate_y: base_translate_y},
        cur_char_rotation
      ) do
    "translate(#{base_translate_x},#{base_translate_y}) rotate(#{map_angle(cur_char_rotation)}, #{
      base_translate_x
    }, #{base_translate_y})"
  end

  def marker_transform(
        %Course{
          marker_center_offset_x: marker_center_offset_x,
          marker_center_offset_y: marker_center_offset_y
        },
        cur_char_rotation,
        [cur_char_x, cur_char_y],
        marker_rotation_offset,
        marker_translate_offset_x,
        marker_translate_offset_y
      ) do
    marker_translate_offset_x = -8
    marker_translate_offset_y = 24

    "rotate(#{cur_char_rotation + marker_rotation_offset}, #{cur_char_x}, #{cur_char_y}) translate(#{
      cur_char_x - marker_center_offset_x + marker_translate_offset_x
    }, #{cur_char_y - marker_center_offset_y + marker_translate_offset_y}) scale(0.07)"
  end

  def cur_text_path_id(%Game{} = game, player_index) when is_integer(player_index) do
    "text-path-#{cur_path_char_index(game, player_index) |> Map.get(:path_index)}"
  end

  def cur_char_index(%Game{} = game, player_index) when is_integer(player_index) do
    cur_path_char_index(game, player_index)
    |> Map.get(:char_index)
  end

  def map_angle(cur_char_rotation), do: -1 * cur_char_rotation

  def text_segments(%Game{} = _game) do
    # TODO: implement this for real
    [
      {"foo bar", "orange"},
      {"blue baz", "blue"}
    ]
  end

  defp cur_path_char_index(%Game{} = game, player_index) when is_integer(player_index) do
    %Player{cur_path_char_indices: cur_path_char_indices} = Enum.at(game.players, player_index)
    hd(cur_path_char_indices)
  end
end
