defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView
  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(500, self(), :tick)

    # template = :random
    # socket =
    #   assign(socket,
    #     universe: rand_bytes(),
    #     template: template,
    #     dimensions: {8, 8}
    #   )

    template = :pulsar

    socket =
      assign(socket,
        universe: rand_bytes(),
        template: template,
        dimensions: Template.dimensions(template)
      )

    Universe.start_link(%{
      name: socket.assigns.universe,
      dimensions: socket.assigns.dimensions,
      template: socket.assigns.template
    })

    {:ok, put_cells(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket), do: {:noreply, put_cells(socket, &Universe.tick/1)}

  defp put_cells(socket, f), do: assign(socket, cells: f.(socket.assigns.universe))

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)
end
