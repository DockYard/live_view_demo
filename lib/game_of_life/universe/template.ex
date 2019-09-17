# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule GameOfLife.Universe.Template do
  alias GameOfLife.Universe.Dimensions
  alias GameOfLife.Cell.Position

  def dimensions(:beacon), do: %Dimensions{width: 6, height: 6}
  def dimensions(:pulsar), do: %Dimensions{width: 17, height: 17}
  def dimensions(:penta_decathlon), do: %Dimensions{width: 11, height: 18}

  def initial_state(:beacon) do
    [
      %Position{x: 1, y: 1},
      %Position{x: 1, y: 2},
      %Position{x: 2, y: 1},
      %Position{x: 3, y: 4},
      %Position{x: 4, y: 3},
      %Position{x: 4, y: 4}
    ]
  end

  def initial_state(:pulsar) do
    [
      %Position{x: 4, y: 2},
      %Position{x: 5, y: 2},
      %Position{x: 6, y: 2},
      %Position{x: 10, y: 2},
      %Position{x: 11, y: 2},
      %Position{x: 12, y: 2},
      %Position{x: 2, y: 4},
      %Position{x: 7, y: 4},
      %Position{x: 9, y: 4},
      %Position{x: 14, y: 4},
      %Position{x: 2, y: 5},
      %Position{x: 7, y: 5},
      %Position{x: 9, y: 5},
      %Position{x: 14, y: 5},
      %Position{x: 2, y: 6},
      %Position{x: 7, y: 6},
      %Position{x: 9, y: 6},
      %Position{x: 14, y: 6},
      %Position{x: 4, y: 7},
      %Position{x: 5, y: 7},
      %Position{x: 6, y: 7},
      %Position{x: 10, y: 7},
      %Position{x: 11, y: 7},
      %Position{x: 12, y: 7},
      %Position{x: 4, y: 9},
      %Position{x: 5, y: 9},
      %Position{x: 6, y: 9},
      %Position{x: 10, y: 9},
      %Position{x: 11, y: 9},
      %Position{x: 12, y: 9},
      %Position{x: 2, y: 10},
      %Position{x: 7, y: 10},
      %Position{x: 9, y: 10},
      %Position{x: 14, y: 10},
      %Position{x: 2, y: 11},
      %Position{x: 7, y: 11},
      %Position{x: 9, y: 11},
      %Position{x: 14, y: 11},
      %Position{x: 2, y: 12},
      %Position{x: 7, y: 12},
      %Position{x: 9, y: 12},
      %Position{x: 14, y: 12},
      %Position{x: 4, y: 14},
      %Position{x: 5, y: 14},
      %Position{x: 6, y: 14},
      %Position{x: 10, y: 14},
      %Position{x: 11, y: 14},
      %Position{x: 12, y: 14}
    ]
  end

  def initial_state(:penta_decathlon) do
    [
      %Position{x: 4, y: 5},
      %Position{x: 4, y: 6},
      %Position{x: 4, y: 7},
      %Position{x: 4, y: 8},
      %Position{x: 4, y: 9},
      %Position{x: 4, y: 10},
      %Position{x: 4, y: 11},
      %Position{x: 4, y: 12},
      %Position{x: 5, y: 5},
      %Position{x: 5, y: 7},
      %Position{x: 5, y: 8},
      %Position{x: 5, y: 9},
      %Position{x: 5, y: 10},
      %Position{x: 5, y: 12},
      %Position{x: 6, y: 5},
      %Position{x: 6, y: 6},
      %Position{x: 6, y: 7},
      %Position{x: 6, y: 8},
      %Position{x: 6, y: 9},
      %Position{x: 6, y: 10},
      %Position{x: 6, y: 11},
      %Position{x: 6, y: 12}
    ]
  end
end
