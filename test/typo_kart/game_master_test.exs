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
                 },
                 %Player{
                   label: "bar",
                   color: "blue"
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
                 ],
                 start_positions_by_player_count: [
                   [%PathCharIndex{path_index: 0, char_index: 0}], # one player
                   [%PathCharIndex{path_index: 0, char_index: 0}, %PathCharIndex{path_index: 1, char_index: 2}] # two players
                 ],
               }
             })

    assert %{
             games: %{
               ^id => %Game{
                 players: [
                   %Player{
                     label: "foo",
                     color: "orange",
                     cur_path_char_indices: [
                       %PathCharIndex{path_index: 0, char_index: 0}
                     ]
                   },
                   %Player{
                     label: "bar",
                     color: "blue",
                     cur_path_char_indices: [
                       %PathCharIndex{path_index: 1, char_index: 2}
                     ]
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
  test "next_chars/2 single path, with no connections" do
    course = %Course{
      paths: [
        %Path{
          chars: 'fox'
        }
      ],
      path_connections: []
    }

    assert [
             %PathCharIndex{path_index: 0, char_index: 2}
           ] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 1})
  end

  @tag :next_chars
  test "next_chars/2 wrap around on the current path if there's an explicit path_connection linking it back to itself" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("fox")
        }
      ],
      path_connections: [
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
      path_connections: []
    }

    assert [] = GameMaster.next_chars(course, %PathCharIndex{path_index: 0, char_index: 2})
  end

  @tag :next_chars
  test "next_chars/2 when cur char is a connection point" do
    course = %Course{
      paths: [
        %Path{
          chars: 'fox'
        },
        %Path{
          chars: 'red'
        }
      ],
      path_connections: [
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
        %Player{}
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'The quick brown fox'
          }
        ],
        start_positions_by_player_count: [
          [%PathCharIndex{path_index: 0, char_index: 4}]
        ],
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
  test "advance/3 following a path connection" do
    course = %Course{
      paths: [
        %Path{
          chars: 'fox'
        },
        %Path{
          chars: 'turtle'
        }
      ],
      start_positions_by_player_count: [
        [%PathCharIndex{path_index: 0, char_index: 0}]
      ],
      path_connections: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 1},
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

    assert {:ok, _} = GameMaster.advance(game_id, 0, hd('f'))
    assert {:ok, _} = GameMaster.advance(game_id, 0, hd('o'))
    assert {:ok, game} = GameMaster.advance(game_id, 0, hd('t'))

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
                 0,
                 0,
                 nil,
               ],
               [
                 0,
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
  test "advance/3 remaining on the same path passing a connection point" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        },
        %Path{
          chars: String.to_charlist("A slow green turtle")
        }
      ],
      path_connections: [
        {
          # A player can advance directly from this point...
          %PathCharIndex{path_index: 0, char_index: 9},
          # ...to this point.
          %PathCharIndex{path_index: 1, char_index: 0}
        }
      ],
      start_positions_by_player_count: [
        [%PathCharIndex{path_index: 0, char_index: 10}]
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
      path_connections: []
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
  test "advance/3 invalid keyCode at a path connection" do
    course = %Course{
      paths: [
        %Path{
          chars: String.to_charlist("The quick brown fox")
        },
        %Path{
          chars: String.to_charlist("A slow green turtle")
        }
      ],
      path_connections: [
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
  test "text_segments/3 when current player is at a path connection point and the char on other path is unowned" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 13
            },
            %PathCharIndex{
              path_index: 1,
              char_index: 6
            }
          ]
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
        ],
        path_connections: [
          {
            # ... from this character
            %PathCharIndex{path_index: 0, char_index: 12},
            # ... player can move to this character
            %PathCharIndex{path_index: 1, char_index: 6}
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
             {"ro", "unowned"},
             {"w", "unowned next-char"},
             {"n ", "unowned"},
             {"fox", "blue"}
           ] = GameMaster.text_segments(game, 0, 0)

    assert [
             {"A", "orange"},
             {" slo", "blue"},
             {"w", "unowned"},
             {" ", "unowned next-char"},
             {"green tu", "unowned"},
             {"rtl", "orange"},
             {"e", "unowned"}
           ] = GameMaster.text_segments(game, 1, 0)
  end

  @tag :text_segments
  test "text_segments/3 when current player is at a path connection point and the char on other path is owned" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 13
            },
            %PathCharIndex{
              path_index: 1,
              char_index: 3
            }
          ]
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
        ],
        path_connections: [
          {
            # ... from this character
            %PathCharIndex{path_index: 0, char_index: 12},
            # ... player can move to this character
            %PathCharIndex{path_index: 1, char_index: 3}
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
             {"ro", "unowned"},
             {"w", "unowned next-char"},
             {"n ", "unowned"},
             {"fox", "blue"}
           ] = GameMaster.text_segments(game, 0, 0)

    assert [
             {"A", "orange"},
             {" s", "blue"},
             {"l", "blue next-char"},
             {"o", "blue"},
             {"w green tu", "unowned"},
             {"rtl", "orange"},
             {"e", "unowned"}
           ] = GameMaster.text_segments(game, 1, 0)
  end

  @tag :text_segments
  test "text_segments/3 when first character on path is unowned and a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 0
            }
          ]
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'fox'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          nil,
          0,
          0
        ]
      ]
    }

    assert [
             {"f", "unowned next-char"},
             {"ox", "orange"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :text_segments
  test "text_segments/3 when first character on path is owned and a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 0
            }
          ]
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'fox'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          1,
          nil,
          nil
        ]
      ]
    }

    assert [
             {"f", "blue next-char"},
             {"ox", "unowned"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :text_segments
  test "text_segments/3 when last character on path is owned and a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 2
            }
          ]
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'fox'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          0,
          0,
          1
        ]
      ]
    }

    assert [
             {"fo", "orange"},
             {"x", "blue next-char"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :text_segments
  test "text_segments/3 when last character on path is unowned a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 2
            }
          ]
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'fox'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          0,
          0,
          nil
        ]
      ]
    }

    assert [
             {"fo", "orange"},
             {"x", "unowned next-char"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :text_segments
  test "text_segments/3 when last character on path is owned by the same player, and is a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 2
            }
          ]
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'fox'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          0,
          0,
          0
        ]
      ]
    }

    assert [
             {"fo", "orange"},
             {"x", "orange next-char"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :text_segments
  test "text_segments/3 when owner changes in the middle of the path on a next-char" do
    game = %Game{
      players: [
        %Player{
          color: "orange",
          cur_path_char_indices: [
            %PathCharIndex{
              path_index: 0,
              char_index: 2
            }
          ]
        },
        %Player{
          color: "blue"
        }
      ],
      course: %Course{
        paths: [
          %Path{
            chars: 'blast'
          }
        ],
        path_connections: []
      },
      char_ownership: [
        [
          0,
          0,
          1,
          1,
          1
        ]
      ]
    }

    assert [
             {"bl", "orange"},
             {"a", "blue next-char"},
             {"st", "blue"}
           ] = GameMaster.text_segments(game, 0, 0)
  end

  @tag :add_player
  test "add_player/2" do
    game_id = GameMaster.new_game()

    assert {:ok, %Game{}, _player} = GameMaster.add_player(game_id, %Player{})
  end

  @tag :add_player
  test "add_player/2 will not add more than three players (for now)" do
    game_id = GameMaster.new_game()

    assert {:ok, %Game{}, %Player{id: player1_id, color: player1_color}} = GameMaster.add_player(game_id, %Player{})
    assert {:ok, %Game{}, %Player{id: player2_id, color: player2_color}} = GameMaster.add_player(game_id, %Player{})
    assert {:ok, %Game{}, %Player{id: player3_id, color: player3_color}} = GameMaster.add_player(game_id, %Player{})
    assert {:error, "This game has already reached the maximum of players allowed: 3."} =
      GameMaster.add_player(game_id, %Player{})

    refute player1_color == player2_color
    refute player1_color == player3_color
    refute player2_color == player3_color

    refute player1_id == player2_id
    refute player1_id == player3_id
    refute player2_id == player3_id
  end

  @tag :remove_player
  test "remove_player/2" do
    game_id = GameMaster.new_game()

    assert {:ok, _game, %Player{id: player1_id}} = GameMaster.add_player(game_id, %Player{})

    assert {:ok, %Game{players: []}} = GameMaster.remove_player(game_id, player1_id)
  end

  @tag :remove_player
  test "remove_player/2 when the player is not found" do
    game_id = GameMaster.new_game()

    assert {:ok, _game, %Player{id: player1_id}} = GameMaster.add_player(game_id, %Player{})

    assert {:ok, %Game{players: [%Player{id: ^player1_id}]}} = GameMaster.remove_player(game_id, "x#{player1_id}")
  end
end
