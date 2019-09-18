defmodule TypoKart.GameMasterTest do
  use TypoKart.PlainCase

  alias TypoKart.{
    Game,
    GameMaster,
    Player
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

  test "creates a game with some initialization" do
    assert id = GameMaster.new_game(%Game{
      players: [
        %Player{
          label: "foo",
          color: "orange"
        }
      ]
    })

    assert %{
      games: %{
        ^id => %Game{
          players: [
            %Player{
              label: "foo",
              color: "orange"
            }
          ]
        }
      }
    } = GameMaster.state()
  end
end
