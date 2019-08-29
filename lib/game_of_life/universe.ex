defmodule GameOfLife.Universe do
  use GenServer
  require Logger

  @moduledoc """
  GameOfLife.Universe.Supervisor.start_child("u1", {5, 5})
  GameOfLife.Universe.tick("u1")
  GameOfLife.Universe.info("u1", 0)
  """

  alias GameOfLife.Cell

  ## Client

  def start_link(%{name: name, dimensions: dimensions}) do
    GenServer.start_link(
      __MODULE__,
      %{name: name, dimensions: dimensions, generation: 0},
      name: via_tuple(name)
    )
  end

  def stop(name), do: GenServer.stop(via_tuple(name))

  def crash(name), do: GenServer.cast(via_tuple(name), :crash)

  def tick(name), do: GenServer.call(via_tuple(name), :tick)

  def info(name, generation), do: GenServer.call(via_tuple(name), {:info, generation})
  def info(name), do: GenServer.call(via_tuple(name), :info)

  ## Server

  @impl true
  def init(%{name: name} = state) do
    GameOfLife.Cell.Supervisor.start_link(name)

    initialize_cells(state)

    {:ok, state}
  end

  @impl true
  def handle_call(:tick, _from, %{generation: generation} = state) do
    state = Map.put(state, :generation, generation + 1)
    cells = each_cell(state, &Cell.tick/3)
    print_universe(cells)

    {:reply, cells, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    cells = each_cell(state, &Cell.info/3)
    print_universe(cells)

    {:reply, cells, state}
  end

  @impl true
  def handle_call({:info, generation}, _from, state) do
    cells = each_cell(Map.put(state, :generation, generation), &Cell.info/3)
    print_universe(cells)

    {:reply, cells, state}
  end

  @impl true
  def handle_cast(:crash, _state), do: raise("💥kaboom💥")

  ## Utils

  defp initialize_cells(%{name: name, dimensions: {height, width}}) do
    Enum.map(0..height, fn y ->
      Enum.map(0..width, fn x ->
        GameOfLife.Cell.Supervisor.start_child(name, {x, y})
      end)
    end)
  end

  defp print_universe(cells) do
    Enum.each(cells, fn row ->
      Enum.each(row, fn %{alive: alive} ->
        case alive do
          nil -> "-"
          false -> "X"
          true -> "0"
        end
        |> IO.write()
      end)

      IO.puts("")
    end)
  end

  defp each_cell(%{name: name, dimensions: {height, width}, generation: generation}, f) do
    Enum.map(0..height, fn y ->
      Enum.map(0..width, fn x ->
        f.(name, {x, y}, generation)
      end)
    end)
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
