defmodule GameOfLifeWeb.CellView do
  use GameOfLifeWeb, :view

  def render_cell(%{alive: true}), do: content_tag(:div, nil, class: "cell alive")
  def render_cell(%{alive: false}), do: content_tag(:div, nil, class: "cell dead")
  def render_cell(_cell), do: content_tag(:div, "-", class: "cell")
end
