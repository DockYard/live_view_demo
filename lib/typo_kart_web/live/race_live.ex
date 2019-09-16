defmodule TypoKartWeb.RaceLive do
  use Phoenix.LiveView

  require Logger

  # See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/keyCode
  @ignored_key_codes [
    8,  # Backspace
    13, # Enter
    16, # Shift
    17, # Control
    18, # Alt
    20, # Caps Lock
    27, # Esc
    33, # PageUp
    34, # PageDown
    35, # End
    36, # Home
    37, # ArrowLeft
    38, # ArrowUp
    39, # ArrowRight
    40, # ArrowDown
    46, # Delete
    45, # Insert
    93, # Meta
  ]

  @full_text "Two households, both alike in dignity, In fair Verona, where we lay our scene,"

  def render(assigns) do
    TypoKartWeb.RaceView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    # Reminder: mount() is called twice, once for the static HTML mount,
    # and again when the websocket is mounted.
    # We can test whether it's the latter case with:
    #
    # connected?(socket)

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

  def handle_event("key", %{"key" => key}, %{
    assigns: %{
      full_text: full_text,
      cur_text: cur_text,
      cur_text_range: cur_char_num.._
    }
  } = socket) when (key == cur_text) or (key == "_" and cur_text == " ") do
    next_char_num = cur_char_num + 1
    {
      :noreply,
      assign(
        socket,
        Keyword.merge(
          [
            status_class: "",
            cur_char_num: next_char_num
          ],
          text_ranges(next_char_num, full_text)
        )
      )
    }
  end

  def handle_event("key", %{"keyCode" => keyCode}, socket)
    when keyCode in @ignored_key_codes,
    do: {:noreply, socket}

  def handle_event("key", _, socket),
    do: {:noreply, assign(socket, status_class: "error")}

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
