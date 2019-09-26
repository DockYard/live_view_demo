defmodule GameOfLife.Color do
  @moduledoc false

  alias __MODULE__

  defstruct red: "0", green: "0", blue: "0"

  def rgb_string(%Color{red: r, green: g, blue: b}), do: "rgb(#{r},#{g},#{b})"
end
