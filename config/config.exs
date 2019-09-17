# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :live_view_demo,
  ecto_repos: [LiveViewDemo.Repo]

# Configures the endpoint
config :live_view_demo, LiveViewDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iJ7glGCyw4eapkSx2pjea7VbmjcCktuyZFZ7e5KxjzBIa5iQ9Lx2kf1xoY0Yqk/T",
  render_errors: [view: LiveViewDemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiveViewDemo.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "VllDrpHUwV9PnvYFh1GPGDlX8IaC+lTj"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
