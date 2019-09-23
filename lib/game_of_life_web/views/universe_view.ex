defmodule GameOfLifeWeb.UniverseView do
  use GameOfLifeWeb, :view

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Cell.Position

  def render_universe(%Universe{generation: generation, dimensions: %Dimensions{width: width, height: height}}) do
    Enum.map(0..(height - 1), fn y ->
      content_tag(:div, class: "cell-row") do
        Enum.map(0..(width - 1), fn x ->
          generation
          |> Generation.get_cell(%Position{x: x, y: y})
          |> GameOfLifeWeb.CellView.render_cell()
        end)
      end
    end)
  end
end
