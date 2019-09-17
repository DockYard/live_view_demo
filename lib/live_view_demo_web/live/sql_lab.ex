defmodule LiveViewDemoWeb.SqlLab do
  use Phoenix.LiveView
  import Phoenix.HTML.Form

  alias LiveViewDemo.SqlLab.QueryExecuter

  def render(assigns) do
    ~L"""
    <div class="mainBG flex-one centerItems">
      <div>
        <h1>This is the SQL Lab</h1>
      </div>
      <div>
        <h2>You can run the SELECT queries you'd like<h2>
      </div>
      <div>
        <%= f = form_for :query_form, "#", [phx_submit: :submit_query] %>
          <%= textarea f, :query, value: @query, class: "sql-lab-text-area"%>
          <%= submit "Run", class: "blueButton" %>
        </form>
        </div>
      </div>
      <div>
        <%= if @result do %>
          <div>
            <%= generate_results_table(@result) %>
          </div>
        <% else %>
          <%= if @error do %>
            <div>
              <%= generate_error(@error) %>
            </div>
          <% else %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    # if connected?(socket), do: :timer.send_interval(10_000, self(), :tick)

    {:ok, put_initial_assigns(socket)}
  end

  def handle_event("submit_query", %{"query_form" => %{"query" => query}}, socket) do
    case QueryExecuter.handle_sql_petition(query) do
      {:ok, result} ->
        formatted_result = QueryExecuter.format_result(result)
        {:noreply, assign(socket, result: formatted_result, query: query, error: nil)}

      {:error, error} ->
        formatted_error = QueryExecuter.format_error(error)
        {:noreply, assign(socket, result: nil, query: query, error: formatted_error)}
    end
  end

  defp put_initial_assigns(socket) do
    assign(socket, result: nil, query: "", error: nil)
  end

  defp generate_results_table({columns, rows}) when is_list(columns) and is_list(rows) do
    assigns = nil
    ~L"""
      <h3>Results</h3>
      <table>
        <%= generate_headers_row(columns) %>
        <%= generate_result_rows(rows) %>
      </table>
    """
  end

  defp generate_results_table({nil, nil}) do
    assigns = nil
    ~L"""
      <h3>No results</h3>
    """
  end

  defp generate_results_table(_) do
    assigns = nil
    ~L"""
      <h3>Results</h3>
      <p>Something went wrong when rendering the results.</p>
    """
  end

  defp generate_error(error) do
    assigns =%{error: error}
    ~L"""
      <%= if true do %>
        <p class="sql-error">
          Error: <%= @error %>
        </p>
      <% end %>
    """
  end

  defp generate_headers_row(columns) do
    assigns = %{columns: columns}
    ~L"""
      <tr>
        <%= for column_name <- @columns do %>
          <th><%= column_name %></th>
        <% end %>
      </tr>
    """
  end

  defp generate_result_rows(rows) do
    assigns = %{rows: rows}
    ~L"""
    <%= for row <- @rows do %>
      <tr>
          <%= generate_single_row(row) %>
      </tr>
    <% end %>
    """
  end

  defp generate_single_row(row) do
    assigns = %{row: row}
    ~L"""
    <%= for field <- @row do %>
      <td><%= field %></td>
    <% end %>
    """
  end
end
