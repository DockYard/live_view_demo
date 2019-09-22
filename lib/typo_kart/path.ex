defmodule TypoKart.Path do
  defstruct d: "", chars: ''

  @type t :: %__MODULE__{
          d: binary(),
          chars: charlist()
        }
end
