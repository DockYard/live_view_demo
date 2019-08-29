defmodule LiveViewDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      LiveViewDemoWeb.Endpoint,
      {GameOfLife.Universe.Supervisor, []},
      {Registry, [keys: :unique, name: :gol_registry]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Supervisor.start_link(children, strategy: :one_for_one, name: LiveViewDemo.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiveViewDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
