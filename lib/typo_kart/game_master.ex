defmodule TypoKart.GameMaster do
  use GenServer

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

  def state do
    GenServer.call(__MODULE__, :state)
  end

  #def handle_cast(:new_game, _from, state) do


  #end

  #def handle_cast(:update_game, _from, state) do

  #end
end
