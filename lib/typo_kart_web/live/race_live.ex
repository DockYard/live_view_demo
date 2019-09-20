defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  alias TypoKart.{
    Course,
    Game,
    Path,
    PathChar,
    Player
  }

  require Logger

  # See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode
  @ignored_key_codes [
    8,  # Backspace
    13, # Enter
    16, # Shift
    17, # Control
    18, # Alt
    20, # Caps Lock
    27, # Esc
    33, # PageUp
    34, # PageDown
    35, # End
    36, # Home
    37, # ArrowLeft
    38, # ArrowUp
    39, # ArrowRight
    40, # ArrowDown
    46, # Delete
    45, # Insert
    93, # Meta
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

    game = %Game{
      players: [
        %Player{
          color: "orange",
          label: "P1"
        }
      ]
    }

    map = %Course{
      initial_rotation: 150,
      base_translate_x: 250,
      base_translate_y: 250,
      view_box: "0, 0, 1000, 1000",
      marker_center_offset_x: 20,
      marker_center_offset_y: 20,
      paths: [
        %Path{
          chars: String.to_charlist("Two households, both alike in dignity, In fair Verona, where we lay our scene,"),
          d: "M250.5,406.902 C158.713,155.121 0.5,332.815 0.5,241.423 C0.5,150.031 152.251,-133.524 250.5,75.943 C348.749,285.411 500.5,150.031 500.5,241.423 C500.5,332.815 342.287,658.684 250.5,406.902 z",
        }
      ]
    }

    player = 0

    {
      :ok,
      assign(
        socket,
        Keyword.merge(
          [
            status_class: "",
            map: map,
            game: game,
            player: player,
            cur_char_rotation: map.initial_rotation,
            cur_char_point: [0,0],
            marker_rotation_offset: 90,
            marker_translate_offset_x: -8,
            marker_translate_offset_y: 24
          ]
          #text_ranges(Enum.at(game.players,0).cur_path_char.char, Enum.at(map.paths,0).text)
        )
      )
    }
  end

  def handle_event("key", %{"keyCode" => keyCode}, socket)
    when keyCode in @ignored_key_codes,
    do: {:noreply, socket}

  def handle_event("key", %{"key" => key}, %{
      assigns: %{
        map: map,
        game: game,
        player: player
      }
    } = socket) do
    case advance(map, game, player, key) do
      {:ok, game} ->
        {:noreply, assign(socket, status_class: "", game: game)}

      _ ->
        {:noreply, assign(socket, status_class: "error")}
    end
  end

  def handle_event("key", _, socket),
    do: {:noreply, assign(socket, status_class: "error")}

  def handle_event("adjust_rotation", %{
    "currentCharPoint" => %{ "x" => cur_char_x, "y" => cur_char_y },
    "currentCharRotation" => cur_char_rotation
    }, socket) do
    {:noreply, assign(socket, cur_char_point: [cur_char_x, cur_char_y], cur_char_rotation: cur_char_rotation )}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp text_ranges(cur_char_num, full_text), do: [
      before_text_range: (if cur_char_num == 0, do: -1..0, else: 0..(cur_char_num - 1)),
      cur_text_range: cur_char_num..cur_char_num,
      cur_text: String.slice(full_text, cur_char_num..cur_char_num),
      after_text_range: (cur_char_num + 1)..(String.length(full_text) - 1)
    ]

  @spec advance(Course.t(), Game.t(), integer(), binary()) :: {:ok, Game.t()} | :error
  def advance(%Course{} = map, %Game{} = game, player, key)
  when is_integer(player) and is_binary(key) do


    {:ok, game}

    # %Player{cur_path_chars: cur_path_chars} = Enum.at(game.players, player)

    # Enum.reduce(cur_path_chars, nil, fn (%PathChar{path: path, char: char}, acc) ->
    #   # does this one match the current key?
    #   case String.slice(Enum.at(course_paths, path).text, char..char) do
    #     x when key == x or (key == "_" and x == " ") ->
    #       Logger.debug("GOOD key: advance")
    #       # Mutate the game.
    #       # For the current player who has just keyed something correctly,
    #       # mark the current text slice as his, and then recompute the next
    #       {:ok, game}

    #     bad ->
    #       Logger.debug("BAD Key: player=#{player}, key=#{key}, cur_path=#{cur_path}, cur_char=#{cur_char}, cur_text=\"#{bad}\"")
    #       :error
    #   end

    # end)
    # # Find the first matching cur_path _char
    # with ,
    #   %PathChar{path: cur_path, char: cur_char} <- Enum.find(cur_path_chars, &(&1))
    #   %{text: text} <- Enum.at(map.paths, cur_path) do
    #   case String.slice(text, cur_char..cur_char) do
    #     x when key == x or (key == "_" and x == " ") ->
    #       Logger.debug("GOOD key: advance")
    #       # Mutate the game.
    #       # For the current player who has just keyed something correctly,
    #       # mark the current text slice as his, and then recompute the next
    #       {:ok, game}

    #     bad ->
    #       Logger.debug("BAD Key: player=#{player}, key=#{key}, cur_path=#{cur_path}, cur_char=#{cur_char}, cur_text=\"#{bad}\"")
    #       :error
    #   end
    # else
    #   bad ->
    #     Logger.debug("ERROR: #{inspect(bad)}")
    #     :error
    # end



  end
end
