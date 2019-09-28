defmodule GameOfLifeWeb.UniverseView do
  use GameOfLifeWeb, :view

  alias GameOfLife.Color
  alias GameOfLife.Universe
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Universe.Template
  alias GameOfLife.Cell.Position

  def render_universe(%Universe{generation: generation, dimensions: %Dimensions{width: width, height: height} = dimensions}, opts) do
    content_tag(:section, class: universe_class(dimensions)) do
      Enum.map(0..(height - 1), fn y ->
        content_tag(:div, class: "cell-row") do
          Enum.map(0..(width - 1), fn x ->
            generation
            |> Generation.get_cell(%Position{x: x, y: y})
            |> GameOfLifeWeb.CellView.render_cell(opts)
          end)
        end
      end)
    end
  end

  def play_text(false), do: "Play"
  def play_text(true), do: "Pause"

  def template_names(), do: Template.names()

  defp universe_class(%Dimensions{width: width, height: height}) when width > 200 or height > 200, do: "universe xxl"
  defp universe_class(%Dimensions{width: width, height: height}) when width > 125 or height > 125, do: "universe xl"
  defp universe_class(%Dimensions{width: width, height: height}) when width > 75 or height > 75, do: "universe lg"
  defp universe_class(%Dimensions{width: width, height: height}) when width < 15 or height < 15, do: "universe sm"
  defp universe_class(_dimensions), do: "universe md"
end
