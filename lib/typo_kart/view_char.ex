defmodule TypoKart.ViewChar do
  defstruct x: 0, y: 0, rotation: 0

  @type t :: %__MODULE__{
          x: float(),
          y: float(),
          rotation: float()
        }
end
