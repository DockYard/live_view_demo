defmodule TypoKart.GameMaster do
  use GenServer

  alias TypoKart.Game

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

  def state do
    GenServer.call(__MODULE__, :state)
  end

  def new_game(%Game{} = game \\ %Game{}) do
    GenServer.call(__MODULE__, {:new_game, game})
  end

  #def handle_cast(:new_game, _from, state) do


  #end

  #def handle_cast(:update_game, _from, state) do

  #end
end
