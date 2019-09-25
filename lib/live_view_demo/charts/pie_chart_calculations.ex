defmodule LiveViewDemo.Charts.PieChartCalculations do
  alias LiveViewDemo.Charts.Constants

  @pi :math.pi()

  def generate_chart_data(query_result) do
    # query_result = [
    #   ["first_one", 4],
    #   ["second_one", 6],
    #   ["third_one", 2],
    #   ["fourth_one", 8],
    #   ["fifth_one", 5],
    #   ["sixth_one", 10],
    # ]

    colors = Constants.default_chart_colors()

    total = get_total_count(query_result)
    initial_acc = %{colors: colors, acc_percent: 0, total: total, idx: 0}

    query_result
    |> Enum.map_reduce(initial_acc, &format_slice_data/2 )
    |> elem(0)
  end

  defp get_total_count(query_result) do
    Enum.reduce(query_result, 0, fn ([_label, count], acc) -> count + acc end)
  end

  defp format_slice_data([label, count], acc) do
    percentage = count / acc.total
    new_acc_percent = acc.acc_percent + percentage

    {path_data, text_coords} = get_path_data(acc.acc_percent, new_acc_percent, label)
    fill_color = Enum.at(acc.colors, acc.idx)
    show_label = percentage > 0.1

    slice_data = %{
      label: label,
      percentage: percentage,
      path_data: path_data,
      fill_color: fill_color,
      text_coords: text_coords,
      show_label: show_label
    }

    acc = %{acc | acc_percent: new_acc_percent, idx: acc.idx + 1}
    {slice_data, acc}
  end

  defp get_path_data(initial_percent, final_percent, label) do
    {start_x, start_y} = get_coordinates_from_percent(initial_percent)
    {end_x, end_y} = get_coordinates_from_percent(final_percent)

    start_x = start_x * 100
    start_y = start_y * 100
    end_x = end_x * 100
    end_y = end_y * 100

    large_arc = if (final_percent - initial_percent) > 0.5, do: 1, else: 0

    path_data = "M #{start_x} #{start_y} A 100 100 0 #{large_arc} 1 #{end_x} #{end_y} L 0 0"

    text_coords = get_text_coordinates(start_x, end_x, start_y, end_y, label)
    {path_data, text_coords}
  end

  defp get_coordinates_from_percent(percent) do
    two_pi_times_percent = 2 * @pi * percent
    x = :math.cos(two_pi_times_percent)
    y = :math.sin(two_pi_times_percent)

    {x , y}
  end

  defp get_text_coordinates(start_x, end_x, start_y, end_y, label) do
    y = get_y(start_y, end_y)
    x = get_x(start_x, end_x, label)

    {x, y}
  end

  def get_x(start_x, end_x, label) do
    point = ((start_x + end_x) / 2)

    temp_x=
      cond do
        is_between(point, 0, 15) -> 15
        is_between(point, -15, 0) -> -15
        true -> get_between_limits(point, {-70, 70})
      end

    offset = String.length(label) * 1.8

    temp_x - offset
  end

  def get_y(start_y, end_y) do
    point = ((start_y + end_y) / 2)

    cond do
      is_between(point, 0, 15) -> 15
      is_between(point, -15, 0) -> -15
      true -> get_between_limits(point, {-60, 60})
    end
  end

  defp get_between_limits(point, {min, max}) do
    point
    |> min(max)
    |> max(min)
  end

  defp is_between(point, min, max) when point >= min and point <= max, do: true
  defp is_between(_point, _min, _max), do: false


  # defp coordinates_are_in_same_quad(start_point, end_point) do
  #   (start_point >= 0 and end_point >= 0) or (start_point <= 0 and end_point <= 0)
  # end

end
