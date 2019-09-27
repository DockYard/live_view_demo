defmodule LiveViewDemoWeb.Chart do
  use Phoenix.LiveView

  import Phoenix.HTML.Form

  alias LiveViewDemo.Queries.{CommonQueries, ChartQueries}
  alias LiveViewDemo.Charts.PieChartCalculations

  @chart_type_options [
    {"Pie", :pie},
    {"Bar", :bar},
    {"Line", :line},
    {"Scattered", :scattered}
  ]

  @initial_assigns [
    chart_data: nil,
    chart_type: nil,
    chart_type_options: @chart_type_options,
    columns: nil,
    error: nil,
    table: nil,
    pie_column: nil,
  ]

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems avoid-header">
      <div>
        <h2>Let's make some data visualizations</h1>
      </div>
      <div class="display-flex row">
        <div class="chart-form-column">
          <div>
            <h3>You can build a chart with this simple form<h3>
          </div>
          <div>
          <p>Please select the type of chart you want</p>
          <%= f = form_for :chart_type_form, "#", [phx_change: :select_chart_type] %>
            <%= select f, :chart_type, @chart_type_options, prompt: "Select a chart type", selected: @chart_type, class: "chart-select" %>
          </form>
          <%= generate_table_form(@chart_type, assigns) %>
          <%= if @error do %>
            <%= generate_error(@error) %>
          <% end %>
          </div>
        </div>
        <div class="new-chart-container">
          <%= generate_chart(@chart_type, @chart_data) %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    tables = CommonQueries.get_public_tables()

    {:ok, put_initial_info(socket, tables)}
  end

  def handle_event("select_chart_type", %{"chart_type_form" => %{"chart_type" => chart_type }}, socket) do
    chart_type = if chart_type == "", do: nil, else: chart_type
    {:noreply, assign(socket, chart_type: chart_type)}
  end

  def handle_event("select_table", %{"table_form" => %{"table" => table}}, socket) do
    no_table = table == ""

    {table, columns} =
      if no_table do
        {nil, nil}
      else
        columns = CommonQueries.get_table_columns(table)

        {table, columns}
      end

    {:noreply, assign(socket, table: table, columns: columns)}
  end

  def handle_event("set_pie_column", %{"column_pie_form" => %{"column" => column}}, socket) do
    pie_column = if column == "", do: nil, else: column

    {:noreply, assign(socket, pie_column: pie_column)}
  end

  def handle_event("make_chart", %{"column_pie_form" => %{"column" => column}}, socket) do
    {pie_column, chart_data, error} =
      if column == "" do
        {nil, nil, "Please select a column"}
      else
        {chart_data, error} = validate_and_get_chart_data("pie", column, socket.assigns)

        {column, chart_data, error}
      end

    new_assigns = [pie_column: pie_column, chart_data: chart_data, error: error]
    |> IO.inspect()
    {:noreply, assign(socket, new_assigns)}
  end

  defp put_initial_info(socket, tables) do
    assigns = @initial_assigns ++ [tables: tables]
    assign(socket, assigns)
  end

  defp generate_table_form(nil, _), do: nil

  defp generate_table_form(_, assigns) do
    ~L"""
      <div>
        <p>Please select the table you want to use</p>
        <%= f = form_for :table_form, "#", [phx_change: :select_table] %>
          <%= select f, :table, @tables, prompt: "Select a table", selected: @table, class: "chart-select" %>
        </form>
        <%= generate_third_select(@chart_type, @table, @columns, assigns) %>
      </div>
    """
  end

  defp generate_third_select(_, nil, _, _), do: nil
  defp generate_third_select(_, _, columns, _) when columns in [nil, []], do: nil

  # Pie chart
  defp generate_third_select("pie", _, columns, assigns) do
    ~L"""
      <div>
        <p>
          The pie chart represents the distribution of all
          the records of the table according to their value
          in a selected column.
        </p>
        <p>Please select the column you want to use to group the rows.</p>
        <%= f = form_for :column_pie_form, "#", [phx_change: :set_pie_column, phx_submit: :make_chart, class: "flex-column"] %>
          <%= select f, :column, columns, prompt: "Select a column", selected: @pie_column, class: "chart-select"%>
          <div class="row little-margin-top">
            <%= submit "Chart it!", class: "blueButton" %>
            <button class="blueButton greyishButton little-margin-left">
              Reset
            </button>
          </div>
        </form>
      </div>
    """
  end

  defp generate_third_select("bar", _, _, _) do
    nil
  end

  defp generate_chart(_type, nil), do: nil

  defp generate_chart("pie", chart_data) do
    chart_data = PieChartCalculations.generate_chart_data(chart_data)
    assigns = %{chart_data: chart_data}
    ~L"""
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
    """
  end

  defp generate_error(error) do
    assigns = %{error: error}
    ~L"""
      <p class="sql-error">
        Error: <%= @error %>
      </p>
    """
  end

  defp validate_and_get_chart_data("pie", column, assigns) do
    cond do
      is_nil(assigns.table) -> {nil, "Please select a table"}
      is_nil(column) -> {nil, "Please select a column"}
      true -> get_chart_data_and_error("pie", assigns.table, column)
    end
  end

  defp get_chart_data_and_error("pie", table, column) do
    case get_chart_data("pie", table, column) do
      {:ok, chart_data} -> {chart_data, nil}
      {:error, error} -> {nil, error}
    end
  end

  defp get_chart_data("pie", table, column),
    do: ChartQueries.get_count_for_pie_chart(table, column)

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
end
