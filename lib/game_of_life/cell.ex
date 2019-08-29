defmodule GameOfLife.Cell do
  use GenServer
  require Logger

  ## Client

  def start_link(%{universe_name: universe_name, position: position}) do
    GenServer.start_link(
      __MODULE__,
      %{universe_name: universe_name, position: position},
      name: via_tuple(universe_name, position)
    )
  end

  def tick(universe_name, position), do: GenServer.call(via_tuple(universe_name, position), :tick)

  def crash(universe_name, position), do: GenServer.cast(via_tuple(universe_name, position), :crash)

  def alive?(universe_name, position) do
    if exists?(universe_name, position) do
      GenServer.call(via_tuple(universe_name, position), :alive)
    else
      nil
    end
  end

  ## Server

  @impl true
  def init(state) do
    alive = Enum.random([true, false])
    state = Map.put(state, :alive, alive)

    {:ok, state}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    state = update_cell(state)

    {:reply, Map.get(state, :alive, false), state}
  end

  @impl true
  def handle_call(:alive, _from, state) do
    {:reply, Map.get(state, :alive), state}
  end

  @impl true
  def handle_cast(:crash, _state) do
    raise "crashed"
  end

  ## Utils

  defp update_cell(state) do
    alive_count = state |> neighbor_states() |> Enum.count(& &1)
    alive = Enum.member?([2, 3], alive_count)

    Map.put(state, :alive, alive)
  end

  defp neighbor_states(%{universe_name: universe_name, position: {x, y}}) do
    [
      alive?(universe_name, {x - 1, y}),
      alive?(universe_name, {x - 1, y - 1}),
      alive?(universe_name, {x, y - 1}),
      alive?(universe_name, {x + 1, y - 1}),
      alive?(universe_name, {x + 1, y}),
      alive?(universe_name, {x + 1, y + 1}),
      alive?(universe_name, {x, y + 1}),
      alive?(universe_name, {x + 1, y})
    ]
  end

  defp exists?(name, position) do
    :gol_registry
    |> Registry.lookup(tuple(name, position))
    |> Enum.empty?()
    |> Kernel.!()
  end

  defp via_tuple(universe_name, position), do: {:via, Registry, {:gol_registry, tuple(universe_name, position)}}

  defp tuple(universe_name, position), do: {:cell, universe_name, position}
end
