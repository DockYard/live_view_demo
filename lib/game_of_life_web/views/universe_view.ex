defmodule GameOfLifeWeb.UniverseView do
  use GameOfLifeWeb, :view

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Universe.Template
  alias GameOfLife.Cell.Position

  def render_universe(%Universe{generation: generation, dimensions: %Dimensions{width: width, height: height} = dimensions}, opts) do
    content_tag(:section, class: universe_class(dimensions, opts)) do
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

  def logo_path(true), do: "/images/logo.gif"
  def logo_path(false), do: "/images/logo.png"

  def template_names(), do: Template.names()

  defp universe_class(dimensions, %{party: party, playing: playing}) do
    "universe #{dimension_class(dimensions)}" |> playing?(playing) |> party?(party)
  end

  defp dimension_class(%Dimensions{width: width, height: height}) when width > 200 or height > 200, do: "xxl"
  defp dimension_class(%Dimensions{width: width, height: height}) when width > 125 or height > 125, do: "xl"
  defp dimension_class(%Dimensions{width: width, height: height}) when width > 75 or height > 75, do: "lg"
  defp dimension_class(%Dimensions{width: width, height: height}) when width < 15 or height < 15, do: "sm"
  defp dimension_class(_dimensions), do: "md"

  defp playing?(str, true), do: "#{str} playing"
  defp playing?(str, _), do: str

  defp party?(str, true), do: "#{str} party"
  defp party?(str, _), do: str
end
