# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule GameOfLife.Cell.Supervisor do
  use DynamicSupervisor
  alias GameOfLife.Cell

  def start_link(universe_name), do: DynamicSupervisor.start_link(__MODULE__, [], name: via_tuple(universe_name))

  def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(universe_name, position) do
    DynamicSupervisor.start_child(via_tuple(universe_name), {Cell, %{universe_name: universe_name, position: position}})
  end

  defp via_tuple(universe_name), do: {:via, Registry, {:gol_registry, tuple(universe_name)}}

  defp tuple(universe_name), do: {:cell_supervisor, universe_name}
end
