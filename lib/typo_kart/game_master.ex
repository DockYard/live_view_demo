defmodule TypoKart.GameMaster do
  use GenServer

  alias TypoKart.{
    Game,
    Course,
    Path,
    PathCharIndex,
    Player
  }

  def start_link(_init \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init \\ nil) do
    {:ok, %{
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
    game = initialize_char_ownership(game)
    {:reply, id, put_in(state, [:games, id], game)}
  end

  def handle_call({:advance_game, game_id, player_index, key_code}, _from, state) do
    # If key_code fits one of the characters (we'll take the first one found) indexed by the player's
    # cur_path_char_indices, then we can advance.
    with %Game{course: course, players: players} = game <- Kernel.get_in(state, [:games, game_id]),
      %Player{cur_path_char_indices: cur_path_char_indices} = player <- Enum.at(players, player_index),
      %PathCharIndex{} = valid_index <- Enum.find(cur_path_char_indices, &(char_from_course(course, &1) == key_code)),
      updated_player <- Map.put(player, :cur_path_char_indices, next_chars(course, valid_index)),
      updated_game <- Map.put(game, :players, List.replace_at(players, player_index, updated_player)),
      updated_state <- put_in(state, [:games, game_id], updated_game)
    do
      # TODO:
      # 1. Mark this point on the course as claimed by this player.
      # 2. Accumulate any relevant points as a result of this action
      {:reply, {:ok, updated_game}, updated_state}

    else
      _bad ->
        {:reply, {:error, "bad key_code"}, state}
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
  def char_from_course(%Course{paths: paths}, %PathCharIndex{path_index: path_index, char_index: char_index}) do
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

  @spec next_chars(Course.t(), PathCharIndex.t()) :: list(PathCharIndex.t())
  def next_chars(%Course{paths: paths, path_branches: path_branches}, %PathCharIndex{path_index: cur_path_index, char_index: cur_char_index}) do
    %Path{chars: cur_path_chars} = Enum.at(paths, cur_path_index)

    # 1. Add the next char_index on the current path. It's always a valid next char.
    #    If we're at the end of the path, wrap back around to index 0 on that path.
    cur_path_next_char_index =
      case %PathCharIndex{path_index: cur_path_index, char_index: cur_char_index + 1} do
        %PathCharIndex{char_index: next_char_index} = pci
          when next_char_index < length(cur_path_chars) ->
            pci

        _ ->
          %PathCharIndex{path_index: cur_path_index, char_index: 0}
      end

    # 2. If the next char on the current path is a branch point onto another path,
    #    then add the index on that other path.
    [cur_path_next_char_index] ++
      Enum.reduce(path_branches, [], fn
        {%PathCharIndex{} = pci_from, %PathCharIndex{} = pci_to}, acc when pci_from == cur_path_next_char_index ->
          acc ++ [pci_to]

        _, acc ->
          acc
      end)
  end

  defp initialize_char_ownership(%Game{course: %Course{paths: paths}} = game) do
    game
    |> Map.put(
      :char_ownership,
      Enum.map(paths, fn %Path{chars: chars} ->
        Enum.map(chars, fn _ -> nil end)
      end)
    )
  end
end
