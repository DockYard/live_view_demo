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

  setup do
    GameMaster.reset_all()
  end

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

  test "reset_all re-initializes everything" do
    assert id = GameMaster.new_game()

    assert %{
             games: %{
               ^id => %Game{}
             }
           } = GameMaster.state()

    assert :ok = GameMaster.reset_all()

    {:ok, initial_state} = GameMaster.init()

    assert initial_state == GameMaster.state()
  end

  test "creates a game with some initialization" do
    assert id =
             GameMaster.new_game(%Game{
               players: [
                 %Player{
                   label: "foo",
                   color: "orange"
                 }
               ],
               course: %Course{
                 view_box: "0 0 800 800",
                 paths: [
                   %Path{
                     chars: 'fox'
                   },
                   %Path{
                     chars: 'blue'
                   }
                 ]
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
                 },
                 char_ownership: [
                   [nil, nil, nil],
                   [nil, nil, nil, nil]
                 ]
               }
             }
           } = GameMaster.state()
  end

  test "char_from_course/2 when given a valid index" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        }
      ]
    }

    path_char_index = %PathCharIndex{path_index: 0, char_index: 4}

    assert 113 = GameMaster.char_from_course(course, path_char_index)
  end

  test "char_from_course/2 when given an invalid path index" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        }
      ]
    }

    path_char_index = %PathCharIndex{path_index: 1, char_index: 4}

    assert nil == GameMaster.char_from_course(course, path_char_index)
  end

  test "char_from_course/2 when given an invalid char index" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        }
      ]
    }

    path_char_index = %PathCharIndex{path_index: 0, char_index: 40}

    assert nil == GameMaster.char_from_course(course, path_char_index)
  end

  @tag :next_chars
  test "next_chars/2 single path, with no branches" do
    course = %Course{
      paths: [
        %Path{
          chars: 'fox'
        }
      ],
      path_branches: []
    }

    assert [
             %PathCharIndex{path_index: 0, char_index: 2}
           ] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 1})
  end

  @tag :next_chars
  test "next_chars/2 wrap around on the current path if there's an explicit path_branch linking it back to itself" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("fox")
        }
      ],
      path_branches: [
        {
          # ... from this character
          %PathCharIndex{path_index: 0, char_index: 2},
          # ... player can move to this character
          %PathCharIndex{path_index: 0, char_index: 0}
        }
      ]
    }

    assert [
             %PathCharIndex{path_index: 0, char_index: 0}
           ] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 2})
  end

  @tag :next_chars
  test "next_chars/2 empty when at the end of the current path and there's no explicit connection to any other path." do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("fox")
        }
      ],
      path_branches: []
    }

    assert [] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 2})
  end

  @tag :next_chars
  test "next_chars/2 when cur char is a branch point" do
    course = %Course{
      paths: [
        %Path{
          chars: 'fox'
        },
        %Path{
          chars: 'red'
        }
      ],
      path_branches: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 1},
          # ...to this point.
          %PathCharIndex{path_index: 1, char_index: 0}
        }
      ]
    }

    assert [
             %PathCharIndex{path_index: 0, char_index: 2},
             %PathCharIndex{path_index: 1, char_index: 0}
           ] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 1})
  end

  @tag :advance
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
      course: %Course{
        paths: [
          %Path{
            chars: 'The quick brown fox'
          }
        ]
      }
    }

    assert game_id = GameMaster.new_game(game)

    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('q'))

    assert %Game{
             players: [
               %Player{
                 cur_path_char_indices: [
                   %PathCharIndex{
                     path_index: 0,
                     # incremented
                     char_index: 5
                   }
                 ]
               }
             ],
             char_ownership: [
               [
                 nil,
                 nil,
                 nil,
                 nil,
                 0,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil
               ]
             ]
           } = game
  end

  @tag :advance
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
             players: [
               %Player{
                 cur_path_char_indices: [
                   %PathCharIndex{
                     path_index: 1,
                     # moved onto new path
                     char_index: 1
                   }
                 ]
               }
             ],
             char_ownership: [
               [
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil
               ],
               [
                 0,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil
               ]
             ]
           } = game
  end

  # @tag :advance
  # test "advance/3 continuing on a different path when at the end of the current path" do
  #   course = %Course{
  #     paths: [
  #       %Path{
  #         chars: 'turtle'
  #       },
  #       %Path{
  #         chars: 'go'
  #       }
  #     ],
  #     path_branches: [
  #       {
  #         # A player can advance directly from this point...
  #         %PathCharIndex{path_index: 0, char_index: 4},
  #         # ...to this point.
  #         %PathCharIndex{path_index: 1, char_index: 0}
  #       },
  #       {
  #         %PathCharIndex{path_index: 1, char_index: 1},
  #         %PathCharIndex{path_index: 0, char_index: 0}
  #       }
  #     ]
  #   }

  #   game = %Game{
  #     players: [
  #       %Player{
  #         cur_path_char_indices: [
  #           %PathCharIndex{
  #             path_index: 0,
  #             char_index: 3
  #           }
  #         ]
  #       }
  #     ],
  #     course: course
  #   }

  #   assert game_id = GameMaster.new_game(game)

  #   # The first advance should take us to the first path junction:
  #   assert {:ok, game} = GameMaster.advance(game_id, 0, hd('t'))

  #   assert %Game{
  #            players: [
  #              %Player{
  #                cur_path_char_indices: [
  #                  %PathCharIndex{
  #                    path_index: 0,
  #                    char_index: 4
  #                  },
  #                  %PathCharIndex{
  #                    path_index: 1,
  #                    char_index: 0
  #                  }
  #                ]
  #              }
  #            ]
  #          } = game

  #   # The second advance should take us to the second path junction, which may
  #   # only continue forward onto the next path branch--not wrap around on itself.
  #   assert {:ok, game} = GameMaster.advance(game_id, 0, hd('g'))

  #   assert %Game{
  #            players: [
  #              %Player{
  #                cur_path_char_indices: [
  #                  %PathCharIndex{
  #                    path_index: 0,
  #                    char_index: 0
  #                  }
  #                ]
  #              }
  #            ]
  #          } = game
  # end

  @tag :advance
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

    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('b'))

    assert %Game{
             players: [
               %Player{
                 cur_path_char_indices: [
                   %PathCharIndex{
                     path_index: 0,
                     # advanced along the same path
                     char_index: 11
                   }
                 ]
               }
             ],
             char_ownership: [
               [
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 0,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil
               ],
               [
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil,
                 nil
               ]
             ]
           } = game
  end

  @tag :advance
  test "advance/3 invalid keyCode in the middle of a path" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("fox")
        }
      ],
      path_branches: []
    }

    game = %Game{
      players: [
        %Player{
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 1
            }
          ]
        }
      ],
      course: course
    }

    assert game_id = GameMaster.new_game(game)

    assert {:error, _} = GameMaster.advance(game_id, 0, hd('k'))
  end

  @tag :advance
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

  @tag :text_segments
  test "text_segments/2" do
    game = %Game{
      players: [
        %Player{
          color: "orange"
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'The quick brown fox'
          },
          %Path{
            chars: 'A slow green turtle'
          }
        ]
      },
      char_ownership: [
        [
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          nil,
          nil,
          nil,
          nil,
          nil,
          1,
          1,
          1
        ],
        [
          0,
          1,
          1,
          1,
          1,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          0,
          0,
          0,
          nil
        ]
      ]
    }

    assert [
      {"The quick b", "orange"},
      {"rown ", "unowned"},
      {"fox", "blue"}
    ] = GameMaster.text_segments(game, 0)

    assert [
      {"A", "orange"},
      {" slo", "blue"},
      {"w green tu", "unowned"},
      {"rtl", "orange"},
      {"e", "unowned"},
    ] = GameMaster.text_segments(game, 1)
  end
end
