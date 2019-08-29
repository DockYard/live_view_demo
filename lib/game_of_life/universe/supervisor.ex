# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule GameOfLife.Universe.Supervisor do
  use DynamicSupervisor
  alias GameOfLife.Universe

  def start_link(_arg), do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(name, dimensions) do
    DynamicSupervisor.start_child(__MODULE__, {Universe, %{name: name, dimensions: dimensions}})
  end
end
