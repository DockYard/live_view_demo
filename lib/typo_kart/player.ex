defmodule TypoKart.Player do
  defstruct color: "black",
    label: "",
    cur_path: 0,
    cur_char: 0,
    points: 0

  @type t :: %__MODULE__{
    color: binary(),
    label: binary(),
    cur_path: integer(),
    cur_char: integer(),
    points: integer()
  }
end
