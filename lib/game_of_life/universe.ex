defmodule GameOfLife.Universe do
  alias GameOfLife.Cell
  alias GameOfLife.Cell.Position
  alias GameOfLife.Universe
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Template

  defstruct template: "random", dimensions: %Dimensions{width: 0, height: 0}, generation: %Generation{}

  def init(template, %Dimensions{} = dimensions) do
    %Universe{
      template: template,
      dimensions: dimensions,
      generation: Generation.init(initialize_cells(template, dimensions))
    }
  end

  def tick(%Universe{} = universe), do: %{universe | generation: Generation.init(tick_cells(universe))}

  defp initialize_cells("random", %Dimensions{width: width, height: height}) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        %Cell{
          position: %Position{x: x, y: y},
          alive: Enum.random([true, false])
        }
      end)
    end)
  end

  defp initialize_cells(template, %Dimensions{width: width, height: height}) do
    live_cells = Template.initial_state(template)

    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        position = %Position{x: x, y: y}

        %Cell{
          position: position,
          alive: Enum.member?(live_cells, position)
        }
      end)
    end)
  end

  defp tick_cells(%{generation: generation, dimensions: %Dimensions{width: width, height: height}}) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        position = %Position{x: x, y: y}
        cell = Generation.get_cell(generation, position)

        %Cell{
          position: position,
          alive: Cell.tick(cell, generation)
        }
      end)
    end)
  end
end
