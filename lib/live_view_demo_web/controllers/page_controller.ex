defmodule LiveViewDemoWeb.PageController do
  use LiveViewDemoWeb, :controller

  def index(conn, params) do
    IO.inspect("INSIDE INDEX PAGE")
    render(conn, "index.html", result: 45)
  end

  def sumbit_file
end
