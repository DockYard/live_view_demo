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
      ],
      course: %Course{
        view_box: "0 0 800 800"
      }
    })

    assert %{
      games: %{
        ^id => %Game{
          players: [
            %Player{
              label: "foo",
              color: "orange"
            }
          ],
          course: %Course{
            view_box: "0 0 800 800"
          }
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

  test "advance/3 with valid single path inputs and single current path_char index for given player" do
    game = %Game{
      players: [
        %Player{
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 4
            }
          ]
        }
      ],
      course: %Course{paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        }
      ]}
    }

    assert game_id = GameMaster.new_game(game)

    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('q'))

    assert %Game{
      players: %Player{
        cur_path_char_indices: [
          %PathCharIndex{
            path_index: 0,
            char_index: 5 # incremented
          }
        ]
      }
    } = game
  end

  test "advance/3 following a path branch" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        },
        %Path{
          chars: String.to_charlist("A slow green turtle")
        }
      ],
      path_branches: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 9},
          # ...to this point.
          %PathCharIndex{path_index: 1, char_index: 0}
        }
      ]
    }

    game = %Game{
      players: [
        %Player{
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 10
            },
            %PathCharIndex{
              path_index: 1,
              char_index: 0
            }
          ]
        }
      ],
      course: course
    }

    assert game_id = GameMaster.new_game(game)

    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('A'))

    assert %Game{
      players: %Player{
        cur_path_char_indices: [
          %PathCharIndex{
            path_index: 1,
            char_index: 1 # moved onto new path
          }
        ]
      }
    } = game
  end

  test "advance/3 remaining on the same path passing a branch point" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        },
        %Path{
          chars: String.to_charlist("A slow green turtle")
        }
      ],
      path_branches: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 9},
          # ...to this point.
          %PathCharIndex{path_index: 1, char_index: 0}
        }
      ]
    }

    game = %Game{
      players: [
        %Player{
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 10
            },
            %PathCharIndex{
              path_index: 1,
              char_index: 0
            }
          ]
        }
      ],
      course: course
    }

    assert game_id = GameMaster.new_game(game)

    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('A'))

    assert %Game{
      players: %Player{
        cur_path_char_indices: [
          %PathCharIndex{
            path_index: 0,
            char_index: 11 # advanced along the same path
          }
        ]
      }
    } = game
  end

  test "advance/3 invalid keyCode at a path branch" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        },
        %Path{
          chars: String.to_charlist("A slow green turtle")
        }
      ],
      path_branches: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 9},
          # ...to this point.
          %PathCharIndex{path_index: 1, char_index: 0}
        }
      ]
    }

    game = %Game{
      players: [
        %Player{
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 10
            },
            %PathCharIndex{
              path_index: 1,
              char_index: 0
            }
          ]
        }
      ],
      course: course
    }

    assert game_id = GameMaster.new_game(game)

    assert {:error, _} = GameMaster.advance(game_id, 0, hd('s'))
  end
end
