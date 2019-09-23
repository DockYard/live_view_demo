defmodule GameOfLife.Universe.Generation do
  alias GameOfLife.Cell
  alias GameOfLife.Cell.Position
  alias GameOfLife.Universe.Generation

  defstruct cell_map: %{}

  def init(cells), do: %Generation{cell_map: build_cell_states(cells)}

  def alive?(%Generation{} = generation, %Position{} = position) do
    generation
    |> get_cell(position)
    |> Cell.alive?()
  end

  def get_cell(%Generation{cell_map: cells}, %Position{} = position), do: Map.get(cells, position)

  defp build_cell_states(cells), do: cells |> Enum.map(&{&1.position, &1}) |> Map.new()
end
