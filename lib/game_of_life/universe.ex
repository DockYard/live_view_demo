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
  alias GameOfLife.Universe.Generation
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Cell.Position

  ## Client

  def start_link(%{name: name, template: template, dimensions: %Dimensions{} = dimensions}) do
    GenServer.start_link(
      __MODULE__,
      %{name: name, dimensions: dimensions, template: template},
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

    generation = %Generation{cells: initialize_cells(state)}

    {:ok, add_generation(state, generation)}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    generation = %Generation{cells: each_cell(state, &Cell.tick/1)}

    {:reply, generation, add_generation(state, generation)}
  end

  @impl true
  def handle_call(:info, _from, state), do: {:reply, get_generation(state), state}

  @impl true
  def handle_call({:info, generation}, _from, state) do
    {:reply, get_generation(state, generation), state}
  end

  @impl true
  def handle_cast(:crash, _state), do: raise("💥kaboom💥")

  ## Utils

  defp initialize_cells(%{name: name, dimensions: %Dimensions{width: width, height: height}, template: :random}) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        position = %Position{x: x, y: y}
        alive = Enum.random([true, false])

        GameOfLife.Cell.Supervisor.start_child(%{universe_name: name, position: position, alive: alive})

        {position, alive}
      end)
    end)
    |> Map.new()
  end

  defp initialize_cells(%{name: name, dimensions: %Dimensions{width: width, height: height}, template: template}) do
    live_cells = Template.initial_state(template)

    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        Task.async(fn ->
          position = %Position{x: x, y: y}
          alive = Enum.member?(live_cells, position)

          GameOfLife.Cell.Supervisor.start_child(%{universe_name: name, position: position, alive: alive})

          {position, alive}
        end)
      end)
    end)
    |> Task.yield_many()
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Map.new()
  end

  defp each_cell(%{name: name, dimensions: %Dimensions{width: width, height: height}} = state, f) do
    generation = get_generation(state)

    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        Task.async(fn ->
          position = %Position{x: x, y: y}
          result = f.(%{universe_name: name, position: position, generation: generation})

          {position, result}
        end)
      end)
    end)
    |> Task.yield_many()
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Map.new()
  end

  defp add_generation(state, generation) do
    history = Map.get(state, :history, [])

    Map.put(state, :history, history ++ [generation])
  end

  defp get_generation(state, generation \\ -1) do
    state
    |> Map.get(:history)
    |> Enum.at(generation)
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
