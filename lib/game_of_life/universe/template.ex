# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule GameOfLife.Universe.Template do
  def dimensions(:beacon), do: {6, 6}
  def dimensions(:pulsar), do: {17, 17}
  def dimensions(:penta_decathlon), do: {11, 18}

  def initial_state(:beacon) do
    [
      {1, 1},
      {1, 2},
      {2, 1},
      {3, 4},
      {4, 3},
      {4, 4}
    ]
  end

  def initial_state(:pulsar) do
    [
      {4, 2},
      {5, 2},
      {6, 2},
      {10, 2},
      {11, 2},
      {12, 2},
      {2, 4},
      {7, 4},
      {9, 4},
      {14, 4},
      {2, 5},
      {7, 5},
      {9, 5},
      {14, 5},
      {2, 6},
      {7, 6},
      {9, 6},
      {14, 6},
      {4, 7},
      {5, 7},
      {6, 7},
      {10, 7},
      {11, 7},
      {12, 7},
      {4, 9},
      {5, 9},
      {6, 9},
      {10, 9},
      {11, 9},
      {12, 9},
      {2, 10},
      {7, 10},
      {9, 10},
      {14, 10},
      {2, 11},
      {7, 11},
      {9, 11},
      {14, 11},
      {2, 12},
      {7, 12},
      {9, 12},
      {14, 12},
      {4, 14},
      {5, 14},
      {6, 14},
      {10, 14},
      {11, 14},
      {12, 14}
    ]
  end

  def initial_state(:penta_decathlon) do
    [
      {4, 5},
      {4, 6},
      {4, 7},
      {4, 8},
      {4, 9},
      {4, 10},
      {4, 11},
      {4, 12},
      {5, 5},
      {5, 7},
      {5, 8},
      {5, 9},
      {5, 10},
      {5, 12},
      {6, 5},
      {6, 6},
      {6, 7},
      {6, 8},
      {6, 9},
      {6, 10},
      {6, 11},
      {6, 12}
    ]
  end
end
