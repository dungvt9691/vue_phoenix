use Mix.Config

# Configure your database
config :vue_phoenix, VuePhoenix.Repo,
  username: "dungvt",
  password: "",
  database: "side_project_test",
  hostname: "localhost",
  port: 5431,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vue_phoenix, VuePhoenixWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
