defmodule GameOfLifeWeb.CellView do
  use GameOfLifeWeb, :view

  alias GameOfLife.Cell

  def render_cell(%Cell{alive: true}, opts), do: content_tag(:div, nil, class: "cell", style: style(opts))
  def render_cell(_cell, _color), do: content_tag(:div, nil, class: "cell")

  defp style(%{party: true}), do: background(random_color())
  defp style(%{color: color}), do: background(color)

  defp background(color), do: "background: #{color};"

  defp random_color(), do: Enum.join(["#", :rand.uniform(16_777_216) |> Kernel.-(1) |> Integer.to_string(16)])
end
