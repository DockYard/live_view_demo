defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  alias TypoKart.CourseMap

  def map_transform(%CourseMap{base_translate_x: base_translate_x, base_translate_y: base_translate_y}, cur_char_rotation) do
    "translate(#{base_translate_x},#{base_translate_y}) rotate(#{map_angle(cur_char_rotation)}, #{base_translate_x}, #{base_translate_y})"
  end

  def map_angle(cur_char_rotation), do: -1 * cur_char_rotation
end
