defmodule TypoKart.GameMasterTest do
  use TypoKart.PlainCase

  alias TypoKart.{
    Game,
    GameMaster
  }

  test "initializes" do
    assert %{games: %{}} = GameMaster.state()
  end

  test "creates new default game" do
    assert id = GameMaster.new_game()

    assert %{
      games: %{
        ^id => %Game{}
      }
    } = GameMaster.state()
  end
end
