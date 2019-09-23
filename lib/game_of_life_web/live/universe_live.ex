defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns), do: GameOfLifeWeb.UniverseView.render("show.html", assigns)

  def mount(_session, socket) do
    # {:ok, load_universe(socket, %{template: :beacon, dimensions: Template.dimensions(:beacon)})}
    # {:ok, load_universe(socket, %{template: :pulsar, dimensions: Template.dimensions(:pulsar)})}

    {:ok, load_universe(socket)}
  end

  def handle_info(:tick, socket) do
    if socket.assigns.playing do
      {:noreply, tick(socket)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_speed", %{"universe" => %{"speed" => speed}}, socket) do
    {:noreply, assign(socket, speed: String.to_integer(speed))}
  end

  def handle_event("toggle_playing", _params, socket) do
    {:noreply, toggle_playing(socket)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, reset_universe(socket)}
  end

  defp tick(socket) do
    socket
    |> assign(universe: Universe.tick(socket.assigns.universe))
    |> schedule_tick()
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, trunc(1000 / socket.assigns.speed))

    socket
  end

  defp toggle_playing(socket) do
    socket
    |> assign(playing: !socket.assigns.playing)
    |> schedule_tick()
  end

  defp reset_universe(socket) do
    load_universe(socket, %{
      playing: false,
      speed: socket.assigns.speed,
      template: socket.assigns.template,
      dimensions: socket.assigns.dimensions
    })
  end

  defp load_universe(socket, opts \\ %{}) do
    socket
    |> setup_universe(opts)
    |> start_universe()
  end

  defp setup_universe(socket, opts) do
    assign(
      socket,
      playing: Map.get(opts, :playing, false),
      speed: Map.get(opts, :speed, 5),
      template: Map.get(opts, :template, :random),
      dimensions: Map.get(opts, :dimensions, %Dimensions{width: 32, height: 32})
    )
  end

  defp start_universe(socket) do
    universe = Universe.init(socket.assigns.template, socket.assigns.dimensions)

    assign(socket, :universe, universe)
  end
end
