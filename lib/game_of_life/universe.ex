defmodule GameOfLife.Universe do
  use GenServer

  require Logger

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

  def stop(name), do: GenServer.stop(via_tuple(name), :normal)

  def crash(name), do: GenServer.cast(via_tuple(name), :crash)

  def tick(name), do: GenServer.call(via_tuple(name), :tick)

  def info(name), do: GenServer.call(via_tuple(name), :info)

  ## Server

  @impl true
  def init(%{name: name} = state) do
    GameOfLife.Cell.Supervisor.start_link(name)

    {:ok, Map.put(state, :current_generation, %Generation{cells: initialize_cells(state)})}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    new_generation = %Generation{cells: each_cell(state, &Cell.tick/1)}
    state = Map.put(state, :current_generation, new_generation)

    {:reply, new_generation, state}
  end

  @impl true
  def handle_call(:info, _from, %{current_generation: generation} = state), do: {:reply, generation, state}

  @impl true
  def handle_cast(:crash, _state), do: raise("💥kaboom💥")

  ## Utils

  defp initialize_cells(%{name: name, dimensions: %Dimensions{width: width, height: height}, template: :random}) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        Task.async(fn ->
          position = %Position{x: x, y: y}
          alive = Enum.random([true, false])

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

  defp each_cell(%{name: name, current_generation: current_generation, dimensions: %Dimensions{width: width, height: height}}, f) do
    Enum.flat_map(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        Task.async(fn ->
          position = %Position{x: x, y: y}
          result = f.(%{universe_name: name, position: position, generation: current_generation})

          {position, result}
        end)
      end)
    end)
    |> Task.yield_many()
    |> Enum.map(fn {task, res} -> res || Task.shutdown(task, :brutal_kill) end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Map.new()
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
