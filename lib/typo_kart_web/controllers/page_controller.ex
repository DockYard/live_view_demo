defmodule TypoKartWeb.PageController do
  use TypoKartWeb, :controller

  alias TypoKartWeb.RaceLive

  alias TypoKart.{
    Courses,
    Game,
    GameMaster,
    PathCharIndex,
    Player
  }

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def start_game(conn, _params) do
    conn
    |> live_render(RaceLive, session: %{
      game_id: get_or_init_first_game(),
      player_index: 0
    })
  end

  defp get_or_init_first_game() do
    case GameMaster.state() |> Map.get(:games) |> Map.to_list() do
      [] ->
        {:ok, course} = Courses.load("course2")

        GameMaster.new_game(%Game{
          players: [
            %Player{
              color: "orange",
              label: "P1"
            },
            %Player{
              color: "blue",
              label: "P2"
            }
          ],
          course: course
        })

      [{game_id, _game} | _] ->
        game_id
    end
  end
end
