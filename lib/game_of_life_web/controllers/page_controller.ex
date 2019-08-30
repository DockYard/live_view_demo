defmodule GameOfLifeWeb.PageController do
  use GameOfLifeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
