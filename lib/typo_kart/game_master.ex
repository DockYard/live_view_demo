defmodule TypoKart.GameMaster do
  use GenServer

  alias TypoKart.{
    Game,
    Course,
    Path,
    PathCharIndex
  }

  def start_link(_init \\ nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init \\ nil) do
    {:ok, %{
      games: %{}
    }}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:new_game, game}, _from, state) do
    id = UUID.uuid1()
    {:reply, id, put_in(state, [:games, id], game)}
  end

  def handle_call({:advance_game, game_id, player_index, key_code}, _from, state) do
    {:reply, %Game{}, state}

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
end
