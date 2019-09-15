defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  require Logger

  def render(assigns) do
    TypoKartWeb.RaceView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, assign(socket, alpha: 42)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, alpha: 43)}
  end

  #def handle_event("boom", "", socket) do
  #  Logger.info("BOOM!")
  #  {:noreply, socket}
  #end
end
