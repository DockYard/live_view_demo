defmodule TypoKart.RaceViewTest do
  use TypoKart.PlainCase

  alias TypoKart.{
    Course,
    Game,
    GameMaster,
    Path,
    PathCharIndex,
    Player,
    ViewChar
  }

  alias TypoKartWeb.RaceView

  setup do
    GameMaster.reset_all()

    {
      :ok,
      %{
        view_chars: [
          [
            %ViewChar{x: 1, y: 2, rotation: 45},
            %ViewChar{x: 3, y: 4, rotation: 46},
            %ViewChar{x: 5, y: 6, rotation: 47}
          ],
          [
            %ViewChar{x: 7, y: 8, rotation: 48},
            %ViewChar{x: 9, y: 10, rotation: 49},
            %ViewChar{x: 11, y: 12, rotation: 50},
            %ViewChar{x: 13, y: 14, rotation: 51},
            %ViewChar{x: 15, y: 16, rotation: 52},
            %ViewChar{x: 17, y: 18, rotation: 53}
          ]
        ],
        game: %Game{
          players: [
            %Player{
              color: "orange",
              cur_path_char_indices: [
                %PathCharIndex{
                  path_index: 0,
                  char_index: 1
                }
              ]
            },
            %Player{
              color: "blue",
              cur_path_char_indices: [
                %PathCharIndex{
                  path_index: 0,
                  char_index: 2
                },
                %PathCharIndex{
                  path_index: 1,
                  char_index: 2
                }
              ]
            }
          ],
          course: %Course{
            base_translate_x: 123,
            base_translate_y: 456,
            course_rotation_center_x: 71,
            course_rotation_center_y: 17,
            marker_center_offset_x: 13,
            marker_center_offset_y: 23,
            paths: [
              %Path{
                chars: 'fox'
              },
              %Path{
                chars: 'turtle'
              }
            ],
            path_connections: [
              {
                # A player can advance directly from this point...
                %PathCharIndex{path_index: 0, char_index: 2},
                # ...to this point.
                %PathCharIndex{path_index: 0, char_index: 0}
              },
              {
                # A player can advance directly from this point...
                %PathCharIndex{path_index: 1, char_index: 5},
                # ...to this point.
                %PathCharIndex{path_index: 1, char_index: 0}
              },
              {
                # A player can advance directly from this point...
                %PathCharIndex{path_index: 0, char_index: 1},
                # ...to this point.
                %PathCharIndex{path_index: 1, char_index: 2}
              }
            ]
          }
        }
      }
    }
  end

  test "cur_view_char/3", %{game: game, view_chars: view_chars} do
    assert %ViewChar{x: 3, y: 4, rotation: 46} = RaceView.cur_view_char(game, view_chars, 0)
  end

  test "cur_path_char_index/3", %{game: game} do
    assert %PathCharIndex{path_index: 0, char_index: 2} = RaceView.cur_path_char_index(game, 1)
  end

  test "course_rotation/3", %{game: game, view_chars: view_chars} do
    assert -47 == RaceView.course_rotation(game, view_chars, 1)
  end

  test "course_rotation/3 when view_chars is empty", %{game: game} do
    view_chars = []
    assert 0 == RaceView.course_rotation(game, view_chars, 1)
  end

  test "course_transform/3", %{
    game:
      %Game{
        course: %{
          base_translate_x: btx,
          base_translate_y: bty,
          course_rotation_center_x: rcx,
          course_rotation_center_y: rcy
        }
      } = game,
    view_chars: view_chars
  } do
    assert "translate(#{btx},#{bty}) rotate(-46, #{rcx}, #{rcy})" ==
             RaceView.course_transform(game, view_chars, 0)

    assert "translate(#{btx},#{bty}) rotate(-47, #{rcx}, #{rcy})" ==
             RaceView.course_transform(game, view_chars, 1)
  end

  test "course_transform/3 when view_chars is empty, as on mount", %{
    game:
      %Game{
        course: %{
          base_translate_x: btx,
          base_translate_y: bty,
          course_rotation_center_x: rcx,
          course_rotation_center_y: rcy
        }
      } = game
  } do
    view_chars = []

    assert "translate(#{btx},#{bty}) rotate(0, #{rcx}, #{rcy})" ==
             RaceView.course_transform(game, view_chars, 0)

    assert "translate(#{btx},#{bty}) rotate(0, #{rcx}, #{rcy})" ==
             RaceView.course_transform(game, view_chars, 1)
  end

  test "marker_transform/6", %{game: game, view_chars: view_chars} do
    assert "rotate(#{46 + 91}, 3, 4) translate(#{3 - 13 + 92}, #{4 - 23 + 93}) scale(0.2)" ==
             RaceView.marker_transform(game, view_chars, 0, 91, 92, 93)

    assert "rotate(#{47 + 91}, 5, 6) translate(#{5 - 13 + 92}, #{6 - 23 + 93}) scale(0.2)" ==
             RaceView.marker_transform(game, view_chars, 1, 91, 92, 93)
  end

  test "marker_transform/6 when view_chars is empty, as on mount", %{game: game} do
    view_chars = []
    assert "scale(0.2)" == RaceView.marker_transform(game, view_chars, 0, 91, 92, 93)

    assert "scale(0.2)" == RaceView.marker_transform(game, view_chars, 1, 91, 92, 93)
  end

  test "marker_class/3 when view_chars is empty", %{game: game} do
    view_chars = []

    assert "marker player-0 orange hide" == RaceView.marker_class(game, view_chars, 0)
  end

  test "marker_class/3 when view_chars is not empty", %{game: game} do
    view_chars = [0]

    assert "marker player-0 orange" == RaceView.marker_class(game, view_chars, 0)
  end
end
