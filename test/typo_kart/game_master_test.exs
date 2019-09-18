defmodule TypoKart.GameMasterTest do
  use TypoKart.PlainCase

  alias TypoKart.GameMaster

  test "initializes" do
    assert {:ok, _pid} = GameMaster.start_link()
    assert %{games: []} = GameMaster.state()
  end
end
