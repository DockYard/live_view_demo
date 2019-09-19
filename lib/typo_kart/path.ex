defmodule TypoKart.Path do
  defstruct d: "", text: ""

  @type t :: %__MODULE__{
    d: binary(),
    text: binary()
  }
end
