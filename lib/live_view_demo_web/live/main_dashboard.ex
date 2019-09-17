defmodule LiveViewDemoWeb.MainDashboard do
  use Phoenix.LiveView

  alias LiveViewDemo.Queries.{UserQueries, OrderQueries}

  def render(assigns) do
    IO.inspect(assigns)
    ~L"""
    <div class="mainBG flex-one centerItems">
      <div>
        <h1>Welcome to Visualixir</h1>
        <img src="../../../assets/images/logo_v1_circle.png" />
      </div>
      <div>
        <h2>Let's make some data visualizations<h2>
      </div>
      <div>
        <div class="blueButton">
          <p class="whiteText">New chart</p>
        </div>
      </div>
      <div class="listContainer">
        <div class="listInsideContainer">
          <%= generate_users_table(@users) %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    # if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)

    {:ok, put_user_list(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_user_list(socket)}
  end

  defp put_user_list(socket) do
    users = UserQueries.get_newest_users(10)
    orders = OrderQueries.get_orders_status_count()

    assign(socket, users: users)
  end

  defp generate_users_table([]) do
    assigns = nil
    ~L"""
      <p>Sorry, no users yet</p>
    """
  end

  defp generate_users_table(users) do
    assigns = %{users: users}
    ~L"""
      <div>
        <%= for user <- @users do %>
          <div>
            <%= generate_user_row(user) %>
          </div>
        <% end %>
      </div>
    """
  end

  defp generate_user_row(user) do
    assigns = %{user: user}
    ~L"""
      <div class="row table-row space-around">
        <div>
          <%= user.first_name %>
        </div>
        <div>
          <%= user.last_name %>
        </div>
        <div>
          <%= user.email %>
        </div>
      </div>
    """
  end
end
