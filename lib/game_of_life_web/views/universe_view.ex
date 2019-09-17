defmodule GameOfLifeWeb.UniverseView do
  use GameOfLifeWeb, :view

  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Cell.Position

  def render_generation(%Generation{cells: cells}, %Dimensions{width: width, height: height}) do
    Enum.map(0..(height - 1), fn y ->
      content_tag(:div, class: "cell-row") do
        Enum.map(0..(width - 1), fn x ->
          GameOfLifeWeb.CellView.render_cell(Map.get(cells, %Position{x: x, y: y}))
        end)
      end
    end)
  end
end
