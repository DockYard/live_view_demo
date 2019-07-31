use Mix.Config

# Configure your database
config :typo_kart, TypoKart.Repo,
  username: "postgres",
  password: "postgres",
  database: "typo_kart_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :typo_kart, TypoKartWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
