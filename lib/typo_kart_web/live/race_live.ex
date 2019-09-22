defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  alias TypoKart.{
    Course,
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


    chars = 'Two households, both alike in dignity, In fair Verona, where we lay our scene,'

    game = %Game{
      players: [
        %Player{
          color: "orange",
          label: "P1"
        }
      ],
      course: %Course{
        initial_rotation: 150,
        base_translate_x: 250,
        base_translate_y: 165,
        view_box: "0, 0, 1000, 1000",
        marker_center_offset_x: 20,
        marker_center_offset_y: 20,
        paths: [
          %Path{
            chars: chars,
            d: "M250.5,406.902 C158.713,155.121 0.5,332.815 0.5,241.423 C0.5,150.031 152.251,-133.524 250.5,75.943 C348.749,285.411 500.5,150.031 500.5,241.423 C500.5,332.815 342.287,658.684 250.5,406.902 z"
          }
        ]
      },
      char_ownership: [ Enum.map(chars, fn _ -> nil end) ]
    }

    game_id = GameMaster.new_game(game)

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
    {:noreply,
     assign(socket, cur_char_point: [cur_char_x, cur_char_y], cur_char_rotation: cur_char_rotation)}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}
end
