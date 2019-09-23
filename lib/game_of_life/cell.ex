defmodule GameOfLife.Cell do
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Cell.Position
  alias GameOfLife.Cell

  defstruct position: %Position{}, alive: false

  def tick(%Cell{alive: alive, position: %Position{} = position}, %Generation{} = generation) do
    cell_state(%{
      alive: alive,
      live_neighbor_count: live_neighbor_count(position, generation)
    })
  end

  def alive?(%Cell{alive: alive}), do: alive
  def alive?(_), do: false

  defp cell_state(%{alive: true, live_neighbor_count: 2}), do: true
  defp cell_state(%{alive: true, live_neighbor_count: 3}), do: true
  defp cell_state(%{alive: false, live_neighbor_count: 3}), do: true
  defp cell_state(_), do: false

  defp live_neighbor_count(position, generation) do
    position
    |> neighbor_states(generation)
    |> Enum.count(& &1)
  end

  defp neighbor_states(%Position{x: x, y: y}, generation) do
    [
      Generation.alive?(generation, %Position{x: x - 1, y: y - 1}),
      Generation.alive?(generation, %Position{x: x, y: y - 1}),
      Generation.alive?(generation, %Position{x: x + 1, y: y - 1}),
      Generation.alive?(generation, %Position{x: x - 1, y: y}),
      Generation.alive?(generation, %Position{x: x + 1, y: y}),
      Generation.alive?(generation, %Position{x: x - 1, y: y + 1}),
      Generation.alive?(generation, %Position{x: x, y: y + 1}),
      Generation.alive?(generation, %Position{x: x + 1, y: y + 1})
    ]
  end
end
