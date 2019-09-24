defmodule TypoKart.Path do
  defstruct d: "", chars: '', extra_attrs: %{}, text_path_extra_attrs: %{}

  @type t :: %__MODULE__{
          d: binary(),
          chars: charlist(),
          extra_attrs: map(),
          text_path_extra_attrs: map()
        }
end
