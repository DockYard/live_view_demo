defmodule GameOfLife.Cell do
  use GenServer

  require Logger

  alias GameOfLife.Universe.Generation
  alias GameOfLife.Cell.Position

  ## Client

  def start_link(%{universe_name: universe_name, position: position} = state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(universe_name, position))
  end

  def tick(%{universe_name: universe_name, position: position, generation: %Generation{} = generation}) do
    GenServer.call(via_tuple(universe_name, position), {:tick, generation})
  end

  def info(%{universe_name: universe_name, position: position}) do
    GenServer.call(via_tuple(universe_name, position), :info)
  end

  ## Server

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:tick, generation}, _from, state) do
    alive = cell_state(state, generation)
    state = Map.put(state, :alive, alive)

    {:reply, alive, state}
  end

  @impl true
  def handle_call(:info, _from, state), do: {:reply, state, state}

  ## Utils

  defp cell_state(%{alive: alive} = state, generation) do
    cell_state(%{
      alive: alive,
      live_neighbor_count: live_neighbor_count(state, generation)
    })
  end

  defp cell_state(%{alive: true, live_neighbor_count: 2}), do: true
  defp cell_state(%{alive: true, live_neighbor_count: 3}), do: true
  defp cell_state(%{alive: false, live_neighbor_count: 3}), do: true
  defp cell_state(_), do: false

  defp live_neighbor_count(%{position: position}, generation) do
    position
    |> neighbor_states(generation)
    |> Enum.count(& &1)
  end

  defp neighbor_states(%Position{x: x, y: y}, generation) do
    [
      Generation.alive?(generation, %Position{x: x - 1, y: y - 1}),
      Generation.alive?(generation, %Position{x: x, y: y - 1}),
      Generation.alive?(generation, %Position{x: x + 1, y: y - 1}),
      Generation.alive?(generation, %Position{x: x - 1, y: y}),
      Generation.alive?(generation, %Position{x: x + 1, y: y}),
      Generation.alive?(generation, %Position{x: x - 1, y: y + 1}),
      Generation.alive?(generation, %Position{x: x, y: y + 1}),
      Generation.alive?(generation, %Position{x: x + 1, y: y + 1})
    ]
  end

  defp via_tuple(universe_name, position), do: {:via, Registry, {:gol_registry, tuple(universe_name, position)}}

  defp tuple(universe_name, position), do: {:cell, universe_name, position}
end
