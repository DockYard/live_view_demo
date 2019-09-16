defmodule GameOfLife.Universe do
  use GenServer
  require Logger

  @moduledoc """
  GameOfLife.Universe.start_link("u1", {5, 5})
  GameOfLife.Universe.tick("u1")
  GameOfLife.Universe.info("u1", 0)
  """

  alias GameOfLife.Cell
  alias GameOfLife.Universe.Template

  ## Client

  def start_link(%{name: name, template: template, dimensions: {_width, _height} = dimensions}) do
    GenServer.start_link(
      __MODULE__,
      %{name: name, dimensions: dimensions, template: template, generation: 0},
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

    {:reply, cells, state}
  end

  @impl true
  def handle_call(:info, _from, state) do
    cells = each_cell(state, &Cell.info/3)

    {:reply, cells, state}
  end

  @impl true
  def handle_call({:info, generation}, _from, state) do
    cells = each_cell(Map.put(state, :generation, generation), &Cell.info/3)

    {:reply, cells, state}
  end

  @impl true
  def handle_cast(:crash, _state), do: raise("💥kaboom💥")

  ## Utils

  defp initialize_cells(%{name: name, dimensions: {width, height}, template: :random}) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        {:ok, result} =
          GameOfLife.Cell.Supervisor.start_child(%{
            universe_name: name,
            position: {x, y},
            alive: Enum.random([true, false])
          })

        result
      end)
    end)
  end

  defp initialize_cells(%{name: name, dimensions: {width, height}, template: template}) do
    live_cells = Template.initial_state(template)

    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        {:ok, result} =
          GameOfLife.Cell.Supervisor.start_child(%{
            universe_name: name,
            position: {x, y},
            alive: Enum.member?(live_cells, {x, y})
          })

        result
      end)
    end)
  end

  defp each_cell(%{name: name, dimensions: {width, height}, generation: generation}, f) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        {{x, y}, f.(name, {x, y}, generation)}
      end)
    end)
    |> Map.new()
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
