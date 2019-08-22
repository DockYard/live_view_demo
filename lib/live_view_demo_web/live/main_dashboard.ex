defmodule LiveViewDemoWeb.MainDashboard do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="mainBG">
      <div>
        <h1>Welcome to Visualixir</h1>
      </div>
      <div>
        <h2>Let's make some data visualizations<h2>
      </div>
      <div>
        <div class="blueButton">
          <p class="whiteText">New chart</p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)

    {:ok, put_date(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_date(socket)}
  end

  defp put_date(socket) do
    assign(socket, date: "This is a title")
  end
end
