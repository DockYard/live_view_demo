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

  def tick(universe_name, position, generation), do: GenServer.call(via_tuple(universe_name, position), {:tick, generation})

  def crash(universe_name, position), do: GenServer.cast(via_tuple(universe_name, position), :crash)

  def info(universe_name, position, generation), do: GenServer.call(via_tuple(universe_name, position), {:info, generation})

  def alive?(universe_name, position, generation) do
    if exists?(universe_name, position) do
      GenServer.call(via_tuple(universe_name, position), {:alive, generation})
    else
      nil
    end
  end

  ## Server

  @impl true
  def init(state) do
    alive = Map.get(state, :active, Enum.random([true, false]))
    state = Map.put(state, :history, [alive])

    {:ok, state}
  end

  @impl true
  def handle_call({:tick, generation}, _from, %{universe_name: universe_name, position: position, history: history} = state) do
    alive = cell_state(state, generation - 1)
    history = history ++ [alive]

    {:reply, %{universe_name: universe_name, position: position, alive: alive}, Map.put(state, :history, history)}
  end

  @impl true
  def handle_call({:info, generation}, _from, %{universe_name: universe_name, position: position, history: history} = state) do
    alive = Enum.at(history, generation)

    {:reply, %{universe_name: universe_name, position: position, alive: alive}, state}
  end

  @impl true
  def handle_call({:alive, generation}, _from, %{history: history} = state) do
    {:reply, Enum.at(history, generation), state}
  end

  @impl true
  def handle_cast(:crash, _state), do: raise("💥crash💥")

  ## Utils

  defp cell_state(state, generation) do
    alive_count = state |> neighbor_states(generation) |> Enum.count(& &1)

    Enum.member?([2, 3], alive_count)
  end

  defp neighbor_states(%{universe_name: universe_name, position: {x, y}}, generation) do
    [
      alive?(universe_name, {x - 1, y}, generation),
      alive?(universe_name, {x - 1, y - 1}, generation),
      alive?(universe_name, {x, y - 1}, generation),
      alive?(universe_name, {x + 1, y - 1}, generation),
      alive?(universe_name, {x + 1, y}, generation),
      alive?(universe_name, {x + 1, y + 1}, generation),
      alive?(universe_name, {x, y + 1}, generation),
      alive?(universe_name, {x + 1, y}, generation)
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
