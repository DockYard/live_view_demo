defmodule TypoKart.Course do
  alias TypoKart.{
    Path,
    PathCharIndex
  }

  defstruct initial_rotation: 0,
            base_translate_x: 0,
            base_translate_y: 0,
            marker_center_offset_x: 0,
            marker_center_offset_y: 0,
            course_rotation_center_x: 0,
            course_rotation_center_y: 0,
            start_positions_by_player_count: [
              # one player
              [%PathCharIndex{}],
              # two players
              [%PathCharIndex{}, %PathCharIndex{}]
            ],
            view_box: "",
            paths: [],
            path_connections: []

  @type t :: %__MODULE__{
          initial_rotation: integer(),
          base_translate_x: integer(),
          base_translate_y: integer(),
          view_box: binary(),
          start_positions_by_player_count: list(PathCharIndex.t()),
          marker_center_offset_x: integer(),
          marker_center_offset_y: integer(),
          course_rotation_center_x: integer(),
          course_rotation_center_y: integer(),
          paths: list(Path.t()),
          path_connections: list(PathCharIndex.t())
        }
end
