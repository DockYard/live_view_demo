alias TypoKart.Player

defmodule TypoKart.Game do
  defstruct players: []

  @type t :: %__MODULE__{
    players: list(Player.t())
  }
end
