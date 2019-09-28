defmodule TypoKart.Player do
  alias TypoKart.PathCharIndex

  defstruct id: UUID.uuid1(),
            color: "black",
            label: "",
            points: 0,
            cur_path_char_indices: [%PathCharIndex{}]

  @type t :: %__MODULE__{
          id: binary(),
          color: binary(),
          label: binary(),
          points: integer(),
          cur_path_char_indices: list(PathCharIndex.t())
        }
end
