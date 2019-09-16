defmodule TypoKartWeb.RaceView do
  use TypoKartWeb, :view

  @base_translate_x 250
  @base_translate_y 250

  def map_transform(cur_char_rotation) do
    "translate(#{@base_translate_x},#{@base_translate_y}) rotate(#{map_angle(cur_char_rotation)}, #{@base_translate_x}, #{@base_translate_y})"
  end

  def map_angle(cur_char_rotation), do: -1 * cur_char_rotation
end
