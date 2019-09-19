defmodule TypoKart.Player do
  alias TypoKart.PathChar

  defstruct color: "black",
    label: "",
    points: 0,
    cur_path_char: %PathChar{},
    available_next_path_chars: []

  @type t :: %__MODULE__{
    color: binary(),
    label: binary(),
    points: integer(),
    cur_path_char: PathChar.t(),
    available_next_path_chars: list(PathChar.t())
  }
end
