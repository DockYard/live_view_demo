defmodule TypoKart.PathCharIndex do
  defstruct path_index: 0, char_index: 0

  @type t :: %__MODULE__{
          path_index: integer(),
          char_index: integer()
        }
end
