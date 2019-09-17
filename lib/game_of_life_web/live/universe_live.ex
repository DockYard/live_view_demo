defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView
  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    socket = if connected?(socket), do: set_timer(socket, 6), else: socket

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

  def handle_event("update_speed", %{"speed" => speed}, socket) do
    {:noreply, set_timer(socket, String.to_integer(speed))}
  end

  defp put_cells(socket, f), do: assign(socket, cells: f.(socket.assigns.universe))

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)

  defp set_timer(socket, speed) do
    if Map.has_key?(socket.assigns, :timer_ref) do
      :timer.cancel(socket.assigns.timer_ref)
    end

    # `send_interval` needs an Integer, not a Float
    {:ok, tref} = :timer.send_interval(trunc(2000 / speed), self(), :tick)

    assign(socket, timer_ref: tref)
  end
end
