defmodule GameOfLife.Universe.Generation do
  @moduledoc false

  defstruct cells: %{}

  def alive?(%GameOfLife.Universe.Generation{cells: cells}, position), do: Map.get(cells, position)
end
