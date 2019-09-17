defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(500, self(), :tick)

    # socket = assign(socket, universe: rand_bytes(), template: :random, dimensions: %Dimensions{width: 8, height: 8})
    socket = assign(socket, universe: rand_bytes(), template: :beacon, dimensions: Template.dimensions(:beacon))
    # socket = assign(socket, universe: rand_bytes(), template: :pulsar, dimensions: Template.dimensions(:pulsar))

    Universe.start_link(%{
      name: socket.assigns.universe,
      dimensions: socket.assigns.dimensions,
      template: socket.assigns.template
    })

    {:ok, put_generation(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket), do: {:noreply, put_generation(socket, &Universe.tick/1)}

  defp put_generation(socket, f), do: assign(socket, generation: f.(socket.assigns.universe))

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)
end
