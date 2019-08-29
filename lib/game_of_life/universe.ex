defmodule GameOfLife.Universe do
  use GenServer
  require Logger

  @moduledoc """
  GameOfLife.Universe.Supervisor.start_child("u1", {5, 5})
  GameOfLife.Universe.Supervisor.start_child("u2", {10, 10})
  GameOfLife.Universe.tick("u1")
  """

  alias GameOfLife.Cell

  ## Client

  def start_link(%{name: name, dimensions: dimensions}) do
    GenServer.start_link(
      __MODULE__,
      %{name: name, dimensions: dimensions},
      name: via_tuple(name)
    )
  end

  def stop(name), do: GenServer.stop(via_tuple(name))

  def crash(name), do: GenServer.cast(via_tuple(name), :crash)

  def tick(name), do: GenServer.call(via_tuple(name), :tick)

  ## Server

  @impl true
  def init(%{name: name} = state) do
    GameOfLife.Cell.Supervisor.start_link(name)

    each_cell(state, &GameOfLife.Cell.Supervisor.start_child/2)
    print_universe(state)

    {:ok, state}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    each_cell(state, &Cell.tick/2)

    print_universe(state)

    {:reply, state, state}
  end

  @impl true
  def handle_cast(:crash, _state) do
    raise "imploding"
  end

  ## Utils

  defp print_universe(%{name: name, dimensions: {height, width}}) do
    Enum.each(0..height, fn y ->
      Enum.each(0..width, fn x ->
        case Cell.alive?(name, {x, y}) do
          nil -> "-"
          false -> "X"
          true -> "0"
        end
        |> IO.write()
      end)

      IO.puts("")
    end)
  end

  defp each_cell(%{name: name, dimensions: {height, width}}, f) do
    Enum.each(0..height, fn y ->
      Enum.each(0..width, fn x ->
        f.(name, {x, y})
      end)
    end)
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
