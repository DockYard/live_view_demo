defmodule GameOfLifeWeb.PageController do
  use GameOfLifeWeb, :controller

   def index(conn, params) do
    live_render(conn, GameOfLifeWeb.UniverseLive, session: %{path_params: params})
  end
end
