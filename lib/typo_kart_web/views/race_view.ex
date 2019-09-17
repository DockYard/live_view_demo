defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  alias TypoKart.CourseMap

  def map_transform(%CourseMap{base_translate_x: base_translate_x, base_translate_y: base_translate_y}, cur_char_rotation) do
    "translate(#{base_translate_x},#{base_translate_y}) rotate(#{map_angle(cur_char_rotation)}, #{base_translate_x}, #{base_translate_y})"
  end

  def marker_transform(
    %CourseMap{
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
    "rotate(#{cur_char_rotation + marker_rotation_offset}, #{cur_char_x}, #{cur_char_y}) translate(#{cur_char_x - marker_center_offset_x + marker_translate_offset_x}, #{cur_char_y - marker_center_offset_y + marker_translate_offset_y}) scale(0.07)"
  end

  def map_angle(cur_char_rotation), do: -1 * cur_char_rotation
end
