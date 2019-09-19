defmodule LiveViewDemoWeb.Baseball do
    use Phoenix.LiveView

    @update_frequency 3000

    def render(assigns) do
      LiveViewDemoWeb.BaseballView.render("index.html", assigns)
    end
  
    def mount(_session, socket) do
      if connected?(socket) do
        :timer.send_interval(@update_frequency, self(), :update)
      end
  
      {:ok, assign(socket, feed_msgs: [])}
    end
  
    defp update_value(socket) do
  
      ball_color = calculate_ball_color(Enum.random(70..100))
    
      latest_feed = [
        %{
          pitch: %{
            ball_color: calculate_ball_color(Enum.random(70..100)),
            distanceX: Enum.random(0..250),
            distanceY: Enum.random(0..250),
            speed: Enum.random(7..10) * 100,
            mid_distanceX: 125,
            mid_distanceY: 0,
            pitch_number: 1,
          }
        }
      ]
  
      # every @update_frequency append latest_feed to feed_msgs
      update(socket, :feed_msgs, &(&1 ++ latest_feed))
  
    end
  
    def handle_info(:update, socket) do
      {:noreply, update_value(socket)}
    end
  
    defp calculate_ball_color(speed) when speed >= 70 and speed < 80, do: "green"
    defp calculate_ball_color(speed) when speed >= 80 and speed < 90, do: "blue"
    defp calculate_ball_color(speed) when speed >= 90 and speed <= 100, do: "darkred"
    defp calculate_ball_color(_speed), do: "black"
  end
  