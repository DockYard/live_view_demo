defmodule GameOfLifeWeb.UniverseView do
  use GameOfLifeWeb, :view

  def render_cells(cells, {width, height}) do
    Enum.map(0..(height - 1), fn y ->
      content_tag(:div, class: "cell-row") do
        Enum.map(0..(width - 1), fn x ->
          GameOfLifeWeb.CellView.render_cell(Map.get(cells, {x, y}))
        end)
      end
    end)
  end
end
