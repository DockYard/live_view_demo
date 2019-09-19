defmodule TypoKart.PathChar do
  defstruct path: 0, char: 0

  @type t :: %__MODULE__{
    path: integer(),
    char: integer()
  }
end
