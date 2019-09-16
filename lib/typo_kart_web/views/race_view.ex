defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  def map_transform(_cur_char_num, cur_char_rotation, _map_angle) do
    "translate(250,250) rotate(#{map_angle(cur_char_rotation)}, 250, 250)"
  end

  def map_angle(cur_char_rotation), do: -1 * cur_char_rotation
end
