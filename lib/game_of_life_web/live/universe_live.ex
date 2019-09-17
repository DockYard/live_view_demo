defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    socket = assign(socket, universe: rand_bytes(), speed: 10)

    socket = assign(socket, template: :random, dimensions: %Dimensions{width: 16, height: 8})
    # socket = assign(socket, template: :beacon, dimensions: Template.dimensions(:beacon))
    # socket = assign(socket, template: :pulsar, dimensions: Template.dimensions(:pulsar))

    if connected?(socket), do: schedule_tick(socket)

    Universe.start_link(%{
      name: socket.assigns.universe,
      dimensions: socket.assigns.dimensions,
      template: socket.assigns.template
    })

    {:ok, put_generation(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket) do 
    socket =
      socket
      |> put_generation(&Universe.tick/1)
      |> schedule_tick()

    {:noreply, socket}
  end

  def handle_event("update_speed", %{"speed" => speed}, socket) do
    {:noreply, assign(socket, speed: String.to_integer(speed))}
  end

  defp put_generation(socket, f), do: assign(socket, generation: f.(socket.assigns.universe))

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, trunc(1000 / socket.assigns.speed))
    socket
  end
end
