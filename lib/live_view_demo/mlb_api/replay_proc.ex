defmodule LiveViewDemo.ReplayProc do
    use GenServer

    @default_json_file "./sample_data_nyy.json"
  
    defstruct [:all_plays, :current_play]
  
    def start_link() do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    end
  
    def init([]) do
      state = %{%__MODULE__{} | all_plays: load_json()}
  
      {:ok, state, {:continue, :next_play_timer}}
    end
  
    def handle_info(:next_play, %{all_plays: []} = state) do
      IO.inspect("END OF GAME")
  
      {:noreply, state}
    end
  
    def handle_info(:next_play, state) do
      [current_play | remaining_plays] = state.all_plays
      state = %{state | all_plays: remaining_plays}
      batter = current_play["matchup"]["batter"]
      pitcher = current_play["matchup"]["pitcher"]
  
      IO.inspect("[NEXT PLAY] Batter: #{batter["fullName"]} | Pitcher: #{pitcher["fullName"]}")
  
      Enum.each(current_play_pitches(current_play), fn p ->
        Process.sleep(1_000)
        IO.inspect(p, label: p.pitch_number)
      end)
  
      {:noreply, state, {:continue, :next_play_timer}}
    end
  
    def handle_continue(:next_play_timer, state) do
      Process.send_after(self(), :next_play, 5_000)
  
      {:noreply, state}
    end
  
    def current_play_pitches(%{"matchup" => matchup, "playEvents" => play_events}) do
      Enum.map(play_events, fn p ->
        %{
          batter: matchup["batter"],
          pitcher: matchup["pitcher"],
          count: p["count"],
          call: p["details"]["call"],
          outcome: p["details"]["description"],
          is_ball: p["details"]["isBall"],
          is_strike: p["details"]["isStrike"],
          is_in_play: p["details"]["isInPlay"],
          pitch_type: p["details"]["type"]["description"],
          pitch_speed: p["pitchData"]["endSpeed"],
          pitch_coordinates: p["pitchData"]["coordinates"],
          pitch_number: p["pitchNumber"]
        }
      end)
    end
  
    def load_json(json_file \\ @default_json_file) do
      with {:ok, body} <- File.read(json_file),
           {:ok, json} <- Jason.decode(body) do
        last_play = json["liveData"]["plays"]["currentPlay"]
        all_plays_last_to_first = json["liveData"]["plays"]["allPlays"] |> Enum.reverse()
        [last_play | all_plays_last_to_first] |> Enum.reverse()
      end
    end
  end
  