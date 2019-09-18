defmodule TypoKart.GameMasterTest do
  use TypoKart.PlainCase

  alias TypoKart.GameMaster

  test "initializes" do
    assert %{games: %{}} = GameMaster.state()
  end
end
