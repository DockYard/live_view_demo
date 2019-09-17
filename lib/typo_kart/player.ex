defmodule TypoKart.Player do
  defstruct color: "black",
    label: ""

  @type t :: %__MODULE__{
    color: binary(),
    label: binary()
  }
end
