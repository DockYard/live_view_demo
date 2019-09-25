defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  alias TypoKart.{
    Course,
    Courses,
    Game,
    GameMaster,
    Path,
    PathChar,
    Player
  }

  require Logger

  # See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode
  @ignored_key_codes [
    # Backspace
    8,
    # Enter
    13,
    # Shift
    16,
    # Control
    17,
    # Alt
    18,
    # Caps Lock
    20,
    # Esc
    27,
    # PageUp
    33,
    # PageDown
    34,
    # End
    35,
    # Home
    36,
    # ArrowLeft
    37,
    # ArrowUp
    38,
    # ArrowRight
    39,
    # ArrowDown
    40,
    # Delete
    46,
    # Insert
    45,
    # Meta
    93
  ]

  def render(assigns) do
    TypoKartWeb.RaceView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    # Reminder: mount() is called twice, once for the static HTML mount,
    # and again when the websocket is mounted.
    # We can test whether it's the latter case with:
    #
    # connected?(socket)


    {:ok, course} = Courses.load("course2")

    game_id = GameMaster.new_game(%Game{
      players: [
        %Player{
          color: "orange",
          label: "P1"
        }
      ],
      course: course
    })

    game = GameMaster.state() |> get_in([:games, game_id])

    {
      :ok,
      assign(
        socket,
        error_status: "",
        game: game,
        game_id: game_id,
        player_index: 0,
        cur_char_rotation: game.course.initial_rotation,
        cur_char_point: [0, 0],
        marker_rotation_offset: 90,
        marker_translate_offset_x: -8,
        marker_translate_offset_y: 24
      )
    }
  end

  def handle_event("key", %{"keyCode" => keyCode}, socket)
      when keyCode in @ignored_key_codes,
      do: {:noreply, socket}

  def handle_event(
        "key",
        %{"key" => key},
        %{
          assigns: %{
            game_id: game_id,
            player_index: player_index
          }
        } = socket
      ) do
    case GameMaster.advance(game_id, player_index, String.to_charlist(key) |> hd()) do
      {:ok, game} ->
        {:noreply, assign(socket, error_status: "", game: game, text_segments: GameMaster.text_segments(game, player_index))}

      {:error, _} ->
        {:noreply, assign(socket, error_status: "show")}
    end
  end

  def handle_event("key", _, socket),
    do: {:noreply, assign(socket, error_status: "show")}

  def handle_event(
        "adjust_rotation",
        %{
          "currentCharPoint" => %{"x" => cur_char_x, "y" => cur_char_y},
          "currentCharRotation" => cur_char_rotation
        },
        socket
      ) do
    # {:noreply,
    #  assign(socket, cur_char_point: [cur_char_x, cur_char_y], cur_char_rotation: cur_char_rotation)}
    {:noreply, socket}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}
end
