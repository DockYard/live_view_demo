defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView
  alias GameOfLife.Universe

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(500, self(), :tick)

    socket =
      assign(socket,
        universe: rand_bytes(),
        dimensions: {8, 8}
      )

    Universe.Supervisor.start_child(
      socket.assigns.universe,
      socket.assigns.dimensions
    )

    {:ok, put_cells(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_cells(socket, &Universe.tick/1)}
  end

  defp put_cells(socket, f) do
    cells = f.(socket.assigns.universe)
    assign(socket, cells: cells)
  end

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)
end
