defmodule LiveViewDemoWeb.Examples do
  use Phoenix.LiveView

  alias LiveViewDemo.Queries.{UserQueries, OrderQueries}
  alias LiveViewDemo.Charts.PieChartCalculations

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems avoid-header">
      <div>
        <h2>You can start building a chart by selecting the type<h2>
      </div>
      <div>
        <svg
          viewBox="0 0 200 100"
          style="margin-top: 50px;"
          height="200"
          width="400"
        >
          <line stroke="#595454" x1="5" x2="5" y2="95"></line>
          <line stroke="#595454" y1="95" y2="95" x1="5" x2="200"></line>
          <g>
            <rect x="20" y="40" width="10" height="55" fill="#53a2f2"></rect>
          </g>
          <rect x="40" y="80" width="10" height="15" fill="#53a2f2"></rect>
          <rect x="60" y="50" width="10" height="45" fill="#53a2f2"></rect>
          <rect x="80" y="60" width="10" height="35" fill="#53a2f2"></rect>
          <rect x="100" y="10" width="10" height="85" fill="#53a2f2"></rect>
          <rect x="120" y="25" width="10" height="70" fill="#53a2f2"></rect>
          <rect x="140" y="40" width="10" height="55" fill="#53a2f2"></rect>
          <rect x="160" y="90" width="10" height="5" fill="#53a2f2"></rect>
        </svg>
      </div>
      <div>
      </div>
      <div>
        <svg
          viewBox="-100 -100 200 200"
          style="margin-top: 50px;"
          height="250"
          width="250"
        >
          <%= generate_chart_slices(@chart_data) %>
        </svg>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    # if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)

    UserQueries.get_users_w_most_orders()

    {:ok, put_pie_chart_data(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_user_list(socket)}
  end

  defp put_pie_chart_data(socket) do
    chart_data =
      OrderQueries.get_orders_status_count()
      |> PieChartCalculations.generate_chart_data()

    assign(socket, chart_data: chart_data)
  end

  # def generate_chart(chart_data) do
  #
  # end

  def generate_chart_slices(chart_data) do
    assigns = %{chart_data: chart_data}

    ~L"""
      <%= for slice <- @chart_data do %>
        <g>
          <path fill="<%= slice.fill_color %>" d="<%= slice.path_data %>"></path>
          <%= generate_slice_label(slice) %>
        </g>
      <% end %>
    """
  end

  def generate_slice_label(%{show_label: false}), do: nil

  def generate_slice_label(slice) do
    assigns = %{slice: slice}

    {text_x, text_y} = slice.text_coords

    percentage_text = "#{slice.percentage * 100 |> trunc() }%"

    ~L"""
      <text
        text-anchor="start"
        x="<%= text_x %>"
        y="<%= text_y %>"
        fill="#ffffff"
        font-size="10"
      >
        <%= slice.label %>
        <tspan dy="10" dx="-27">
          <%= percentage_text %>
        </tspan>
      </text>
    """
  end

  defp put_user_list(socket) do
    users = UserQueries.get_newest_users(10)

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
