defmodule TypoKart.GameMasterTest do
  use TypoKart.PlainCase

  alias TypoKart.{
    Game,
    GameMaster,
    Player,
    Course,
    Path,
    PathCharIndex
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

  test "char_from_course/2 when given a valid index" do
    course = %Course{paths: [
      %Path{
        chars: String.to_charlist("The quick brown fox")
      }
    ]}

    path_char_index = %PathCharIndex{path_index: 0, char_index: 4}

    assert 113 = GameMaster.char_from_course(course, path_char_index)
  end

  test "char_from_course/2 when given an invalid path index" do
    course = %Course{paths: [
      %Path{
        chars: String.to_charlist("The quick brown fox")
      }
    ]}

    path_char_index = %PathCharIndex{path_index: 1, char_index: 4}

    assert nil == GameMaster.char_from_course(course, path_char_index)
  end

  test "char_from_course/2 when given an invalid char index" do
    course = %Course{paths: [
      %Path{
        chars: String.to_charlist("The quick brown fox")
      }
    ]}

    path_char_index = %PathCharIndex{path_index: 0, char_index: 40}

    assert nil == GameMaster.char_from_course(course, path_char_index)
  end
end
