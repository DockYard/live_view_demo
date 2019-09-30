defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns), do: GameOfLifeWeb.UniverseView.render("show.html", assigns)

  def mount(%{path_params: path_parmas}, socket) do
    {:ok, load_universe(socket, path_parmas)}
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

  def handle_event("update_color", %{"universe" => %{"color" => color}}, socket) do
    {:noreply, assign(socket, color: color)}
  end

  def handle_event("toggle_playing", _params, socket) do
    {:noreply, toggle_playing(socket)}
  end

  def handle_event("toggle_party", _params, socket) do
    {:noreply, toggle_party(socket)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, reset_universe(socket)}
  end

  def handle_event("setup_universe", %{"universe" => universe_opts}, socket) do
    {:noreply, load_universe(socket, universe_opts)}
  end

  def handle_event("set_template", %{"universe" => %{"template" => template}}, socket) do
    {:noreply, set_template(socket, template)}
  end

  defp set_template(socket, template) do
    load_universe(socket, %{"template" => template})
  end

  defp tick(socket) do
    socket
    |> assign(universe: Universe.tick(socket.assigns.universe))
    |> schedule_tick()
  end

  defp schedule_tick(socket) do
    if socket.assigns.playing do
      Process.send_after(self(), :tick, trunc(1000 / socket.assigns.speed))
    end

    socket
  end

  defp toggle_playing(socket) do
    socket
    |> assign(playing: !socket.assigns.playing)
    |> schedule_tick()
  end

  defp toggle_party(socket) do
    socket = assign(socket, party: !socket.assigns.party)

    cond do
      socket.assigns.party -> start_the_party(socket)
      true -> socket
    end
  end

  defp start_the_party(socket) do
    socket = assign(socket, :speed, 20)

    cond do
      !socket.assigns.playing -> toggle_playing(socket)
      true -> socket
    end
  end

  defp reset_universe(socket) do
    load_universe(socket, %{
      playing: false,
      party: false,
      speed: socket.assigns.speed,
      template: socket.assigns.template,
      dimensions: socket.assigns.dimensions,
      color: socket.assigns.color
    })
  end

  defp load_universe(socket, opts) do
    socket
    |> setup_universe(opts)
    |> start_universe()
  end

  defp start_universe(socket) do
    universe = Universe.init(socket.assigns.template, socket.assigns.dimensions)

    socket
    |> assign(:universe, universe)
    |> schedule_tick()
  end

  defp setup_universe(socket, opts) do
    template = template(opts)

    assign(
      socket,
      party: party(opts),
      color: color(opts),
      playing: playing(opts),
      speed: speed(opts),
      template: template,
      dimensions: dimensions(template, opts)
    )
  end

  defp template(%{"template" => template}), do: template
  defp template(_opts), do: "random"

  defp speed(%{"speed" => speed}) when is_bitstring(speed), do: String.to_integer(speed)
  defp speed(%{"speed" => speed}), do: speed
  defp speed(_opts), do: 5

  defp playing(%{"playing" => "1"}), do: true
  defp playing(%{"playing" => 1}), do: true
  defp playing(_opts), do: false

  defp party(%{"party" => "1"}), do: true
  defp party(%{"party" => 1}), do: true
  defp party(_opts), do: false

  defp color(%{"color" => color}), do: color
  defp color(_opts), do: "#FF4400"

  defp dimensions("random", %{"width" => width, "height" => height}) when is_bitstring(width) and is_bitstring(width) do
    dims = Template.dimensions("random")

    # Even with `min = 1` the user can clear the input field via backspace, so check each field
    # individually and use the default dimension for either if it's empty
    %Dimensions{ dims |
      width: (if bit_size(width) > 0, do: String.to_integer(width), else: dims.width),
      height: (if bit_size(height) > 0, do: String.to_integer(height), else: dims.height)
    }
  end
  defp dimensions(template, _opts), do: Template.dimensions(template)
end
