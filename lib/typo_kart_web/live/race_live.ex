defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  require Logger

  @full_text "Two households, both alike in dignity, In fair Verona, where we lay our scene,"

  def render(assigns) do
    TypoKartWeb.RaceView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    {:ok, assign(socket, alpha: 42, status_class: "", map_angle: 0, cur_char_num: 0, cur_char_rotation: 150, data: text_data(0))}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, alpha: 43)}
  end

  def handle_event("key", %{"key" => key}, %{
    assigns: %{
      data: %{
        cur_text: cur_text,
        cur_text_range: cur_char_num.._
      }
    }
  } = socket) when key == cur_text do
    {:noreply, assign(socket, status_class: "", data: text_data(cur_char_num + 1))}
  end

  def handle_event("key", _, socket) do
    {:noreply, assign(socket, status_class: "error")}
  end

  def handle_event("adjust_rotation", %{
    "currentCharPoint" => cur_char_point,
    "currentCharRotation" => cur_char_rotation,
    "mapAngle" => map_angle
    }, socket) do
    #IO.puts("DEBUG: init_rotations")
    {:noreply, assign(socket, cur_char_point: cur_char_point, cur_char_rotation: cur_char_rotation, map_angle: map_angle )}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp text_data(cur_char_num), do: %{
      full_text: @full_text,
      before_text_range: (if cur_char_num == 0, do: -1..0, else: 0..(cur_char_num - 1)),
      cur_char_num: cur_char_num,
      cur_text_range: cur_char_num..cur_char_num,
      cur_text: String.slice(@full_text, cur_char_num..cur_char_num),
      after_text_range: (cur_char_num + 1)..(String.length(@full_text) - 1)
    }
end
