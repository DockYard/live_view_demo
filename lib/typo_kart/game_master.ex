defmodule TypoKart.GameMaster do
  use GenServer

  alias TypoKart.{
    Game,
    Course,
    Path,
    PathCharIndex,
    Player
  }

  @player_count_limit 3

  @player_colors ["orange", "blue", "green"]

  def start_link(_init \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init \\ nil) do
    {:ok,
     %{
       games: %{}
     }}
  end

  def handle_call(:reset_all, _from, _state) do
    {:ok, reset_state} = init()

    {:reply, :ok, reset_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_game, game}, _from, state) do
    id = UUID.uuid1()
    game =
      game
      |> initialize_char_ownership()
      |> initialize_starting_positions()

    {:reply, id, put_in(state, [:games, id], game)}
  end

  def handle_call({:advance_game, game_id, player_index, key_code}, _from, state) do
    # If key_code fits one of the characters (we'll take the first one found) indexed by the player's
    # cur_path_char_indices, then we can advance.
    with %Game{course: course, players: players} = game <-
           Kernel.get_in(state, [:games, game_id]),
         %Player{cur_path_char_indices: cur_path_char_indices} = player <-
           Enum.at(players, player_index),
         %PathCharIndex{} = valid_index <-
           Enum.find(cur_path_char_indices, &(char_from_course(course, &1) == key_code)),
         updated_player <-
           Map.put(player, :cur_path_char_indices, next_chars(course, valid_index)),
         updated_game <-
           update_char_ownership(game, valid_index, player_index)
           |> Map.put(:players, List.replace_at(players, player_index, updated_player)),
         updated_state <- put_in(state, [:games, game_id], updated_game) do
      # TODO:
      # 1. Mark this point on the course as claimed by this player.
      # 2. Accumulate any relevant points as a result of this action
      {:reply, {:ok, updated_game}, updated_state}
    else
      _bad ->
        {:reply, {:error, "bad key_code"}, state}
    end
  end

  def handle_call({:add_player, game_id, %Player{} = player}, _from, state) do
    case Kernel.get_in(state, [:games, game_id]) do
      %Game{players: players} when length(players) >= @player_count_limit ->
        {:reply, {:error, "This game has already reached the maximum of players allowed: #{@player_count_limit}."}, state}

      %Game{players: players} = game ->
        with player = assign_player_color(game, player),
          game <- Map.put(game, :players, players ++ [player]),
          new_state <- put_in(state, [:games, game_id], game),
          do: {:reply, {:ok, game, player}, new_state}

      _ ->
        {:reply, {:error, "game not found"}, state}
    end
  end

  @spec reset_all() :: :ok
  def reset_all do
    GenServer.call(__MODULE__, :reset_all)
  end

  @spec state() :: map()
  def state do
    GenServer.call(__MODULE__, :state)
  end

  @spec new_game(Game.t()) :: binary()
  def new_game(%Game{} = game \\ %Game{}) do
    GenServer.call(__MODULE__, {:new_game, game})
  end

  @spec char_from_course(Course.t(), PathCharIndex.t()) :: char() | nil
  def char_from_course(%Course{paths: paths}, %PathCharIndex{
        path_index: path_index,
        char_index: char_index
      }) do
    with %Path{} = path <- Enum.at(paths, path_index),
         chars when is_list(chars) <- Map.get(path, :chars) do
      Enum.at(chars, char_index)
    else
      _ ->
        nil
    end
  end

  @spec advance(binary(), integer(), integer()) :: {:ok, Game.t()} | {:error, binary()}
  def advance(game_id, player_index, key_code)
      when is_binary(game_id) and is_integer(player_index) and is_integer(key_code) do
    GenServer.call(__MODULE__, {:advance_game, game_id, player_index, key_code})
  end

  @spec add_player(binary, Player.t()) :: {:ok, Game.t(), Player.t()} | {:error, binary()}
  def add_player(game_id, player \\ %Player{}) when is_binary(game_id) do
    GenServer.call(__MODULE__, {:add_player, game_id, player})
  end

  @spec next_chars(Course.t(), PathCharIndex.t()) :: list(PathCharIndex.t())
  def next_chars(
        %Course{paths: paths, path_connections: path_connections},
        %PathCharIndex{
          path_index: cur_path_index,
          char_index: cur_char_index
        } = cur_pci
      ) do
    %Path{chars: cur_path_chars} = Enum.at(paths, cur_path_index)

    # 1. Add the next char_index on the current path. It's always a valid next char,
    # unless we're at the end of that path.
    next_chars_list =
      case %PathCharIndex{path_index: cur_path_index, char_index: cur_char_index + 1} do
        %PathCharIndex{char_index: next_char_index} = pci
        when next_char_index < length(cur_path_chars) ->
          [pci]

        _ ->
          []
      end

    # 2. If the current char is a connection point to another path, then add that char on the other path.
    next_chars_list ++
      Enum.reduce(path_connections, [], fn
        {%PathCharIndex{} = pci_from, %PathCharIndex{} = pci_to}, acc
        when pci_from == cur_pci ->
          acc ++ [pci_to]

        _, acc ->
          acc
      end)
  end

  @type text_segment() :: {binary(), binary()}
  @spec text_segments(Game.t(), integer(), integer()) :: list(text_segment())
  def text_segments(
        %Game{players: players, course: %{paths: paths}, char_ownership: char_ownership},
        path_index,
        player_index
      )
      when is_integer(path_index) and is_integer(player_index) do
    cur_path_chars = Enum.at(paths, path_index) |> Map.get(:chars)
    cur_char_ownership = Enum.at(char_ownership, path_index)
    player_colors = Enum.map(players, & &1.color)

    player_cur_path_char_indices =
      Enum.at(players, player_index) |> Map.get(:cur_path_char_indices)

    Enum.with_index(cur_char_ownership)
    # Add a boolean to the tuple indicating whether it's a valid next-char
    |> Enum.map(
      &Tuple.append(
        &1,
        # produce true in either case:
        #   A) the current char_index on the current path is present in the current
        #      player's cur_path_char_indices.
        #   B) the
        Enum.find(
          player_cur_path_char_indices,
          fn pci ->
            pci == %PathCharIndex{path_index: path_index, char_index: elem(&1, 1)}
          end
        ) != nil
      )
    )
    |> Enum.reduce(
      %{
        cur_owner: nil,
        next_char_visited_previously: false,
        cur_segment_start: 0,
        last_index: length(cur_path_chars) - 1,
        segments: []
      },
      fn cur,
         %{
           last_index: last_index,
           cur_owner: cur_owner,
           cur_segment_start: cur_segment_start,
           segments: segments
         } = acc ->
        case cur do
          # First char index, when it is a next-char
          {owner, 0, true} ->
            %{
              acc
              | cur_owner: owner,
                cur_segment_start: 1,
                segments: [{owner, 0..0, true}]
            }

          {owner, 0, false} ->
            %{
              acc
              | cur_owner: owner,
                cur_segment_start: 0,
                segments: []
            }

          # When we're on the last index and the owner changed
          {owner, index, is_next_char} when owner != cur_owner and index == last_index ->
            %{
              acc
              | segments:
                  segments ++
                    [
                      {cur_owner, cur_segment_start..(index - 1), false},
                      {owner, index..index, is_next_char}
                    ]
            }

          # When we're on the last index, the owner is unchanged, and it is not a next char
          {_owner, index, false} when index == last_index ->
            %{
              acc
              | segments: segments ++ [{cur_owner, cur_segment_start..index, false}]
            }

          # When we're on the last index, the owner is unchanged, it is a next char,
          # and it should be broken out into its own segment
          {_owner, index, true} when index == last_index and cur_segment_start != last_index ->
            %{
              acc
              | segments:
                  segments ++
                    [
                      {cur_owner, cur_segment_start..(index - 1), false},
                      {cur_owner, index..index, true}
                    ]
            }

          # When we're somewhere in the middle, the owner has changed, it's not a next-char,
          # and it's the start of a new segment.
          {owner, index, false} when owner != cur_owner and cur_segment_start == index ->
            %{
              acc
              | cur_owner: owner,
                # This is the proper behavior when the current index is also the start of a new
                # segment and is not a next-char.
                # For example, when previous char was a next-char, and therefore would have
                # comprised its own segment and forced this char to open a new segment.
                segments: segments
            }

          # When we're somewhere in the middle, the owner has changed, it's not a next-char,
          # and it's not the start of a new segment
          {owner, index, false} when owner != cur_owner ->
            %{
              acc
              | cur_owner: owner,
                cur_segment_start: index,
                segments:
                  segments ++
                    [
                      {cur_owner,
                       cur_segment_start..if(cur_segment_start < index, do: index - 1, else: index),
                       false}
                    ]
            }

          # When we're somewhere in the middle, the owner has changed, and it is a next-char
          {owner, index, true} when owner != cur_owner ->
            %{
              acc
              | cur_owner: owner,
                # next index starts a new segment since this one can only be one char long
                cur_segment_start: index + 1,
                segments:
                  segments ++
                    [
                      {cur_owner, cur_segment_start..(index - 1), false},
                      {owner, index..index, true}
                    ]
            }

          # When we're somewhere in the middle, the owner is unchanged, but it is a next-char
          {owner, index, true} when owner == cur_owner ->
            %{
              acc
              | # next index starts a new segment since this one can only be one char long
                cur_segment_start: index + 1,
                segments:
                  segments ++
                    [
                      {cur_owner, cur_segment_start..(index - 1), false},
                      {cur_owner, index..index, true}
                    ]
            }

          # Leftover default case: When we're somewhere in the middle and the owner has not changed and it's not a next-char,
          # so there's no break in the segment--neither due to an owner change, nor due to a next-char status change.
          # Therefore, we just continue scanning forward, accumulating the segment until one of those statuses changes.
          {_owner, _index, _} ->
            acc
        end
      end
    )
    |> Map.get(:segments)
    |> Enum.map(
      &{
        cur_path_chars |> Enum.slice(elem(&1, 1)) |> List.to_string(),
        case &1 do
          {nil, _range, true} ->
            "#{unowned_class()} #{next_char_class()}"

          {nil, _range, false} ->
            unowned_class()

          {owner, _range, false} ->
            Enum.at(player_colors, owner)

          {owner, _range, true} ->
            "#{Enum.at(player_colors, owner)} #{next_char_class()}"
        end
      }
    )
  end

  defp unowned_class, do: "unowned"

  defp next_char_class, do: "next-char"

  defp initialize_char_ownership(%Game{course: %Course{paths: paths}} = game) do
    game
    |> Map.put(
      :char_ownership,
      Enum.map(paths, fn %Path{chars: chars} ->
        Enum.map(chars, fn _ -> nil end)
      end)
    )
  end

  defp update_char_ownership(
         %Game{char_ownership: char_ownership} = game,
         %PathCharIndex{path_index: path_index, char_index: char_index},
         player_index
       ) do
    game
    |> Map.put(
      :char_ownership,
      char_ownership
      |> List.replace_at(
        path_index,
        Enum.at(char_ownership, path_index)
        |> List.replace_at(char_index, player_index)
      )
    )
  end

  defp initialize_starting_positions(%Game{players: players, course: %Course{start_positions_by_player_count: start_positions}} = game) do
    %Game{
      game |
      players: Enum.with_index(players)
        |> Enum.map(fn {player, player_index} ->
          %Player{
            player |
            cur_path_char_indices: [
              Enum.at(start_positions, length(players) - 1)
              |> Enum.at(player_index)
            ]
          }
        end)
    }
  end

  defp assign_player_color(%Game{players: players}, %Player{} = player) do
    with used_colors <- Enum.map(players, &(&1.color)),
      available_colors <- Enum.reject(@player_colors, fn possible_color ->
          Enum.any?(used_colors, &(&1 == possible_color))
        end),
        do: Map.put(player, :color, Enum.random(available_colors))
  end
end
