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

    cur_char_num = 0
    cur_char_rotation = 150

    {
      :ok,
      assign(
        socket,
        Keyword.merge(
          [
            status_class: "",
            full_text: @full_text,
            cur_char_num: cur_char_num,
            cur_char_rotation: cur_char_rotation,
          ],
          text_ranges(cur_char_num, @full_text)
        )
      )
    }
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, alpha: 43)}
  end

  def handle_event("key", %{"key" => key}, %{
    assigns: %{
      full_text: full_text,
      cur_text: cur_text,
      cur_text_range: cur_char_num.._
    }
  } = socket) when key == cur_text do
    {:noreply, assign(socket, Keyword.merge([status_class: ""], text_ranges(cur_char_num + 1, full_text)))}
  end

  def handle_event("key", _, socket) do
    {:noreply, assign(socket, status_class: "error")}
  end

  def handle_event("adjust_rotation", %{
    "currentCharPoint" => cur_char_point,
    "currentCharRotation" => cur_char_rotation
    }, socket) do
    {:noreply, assign(socket, cur_char_point: cur_char_point, cur_char_rotation: cur_char_rotation )}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  defp text_ranges(cur_char_num, full_text), do: [
      before_text_range: (if cur_char_num == 0, do: -1..0, else: 0..(cur_char_num - 1)),
      cur_text_range: cur_char_num..cur_char_num,
      cur_text: String.slice(full_text, cur_char_num..cur_char_num),
      after_text_range: (cur_char_num + 1)..(String.length(full_text) - 1)
    ]
end
