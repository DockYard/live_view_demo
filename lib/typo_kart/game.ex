defmodule TypoKart.Game do
  alias TypoKart.{
    Course,
    Player
  }

  defstruct players: [], course: %Course{}

  @type t :: %__MODULE__{
    players: list(Player.t()),
    course: Course.t()
  }
end
