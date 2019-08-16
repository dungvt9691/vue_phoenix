# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :vue_phoenix,
  ecto_repos: [VuePhoenix.Repo]

# Configures the endpoint
config :vue_phoenix, VuePhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NbKnX1kFv4DWHAXgDIkRhe4+sXsY89hJyAHIoE7cXnmebPj4gRT/7wIr3k61/APf",
  render_errors: [view: VuePhoenixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VuePhoenix.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, "json-api": Poison

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

config :ja_serializer,
  key_format: :underscored

config :phoenix, VuePhoenix.Endpoint,
  render_errors: [view: VuePhoenix.ErrorView, accepts: ~w(html json json-api)]

# Config email for dev env
config :vue_phoenix, VuePhoenix.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.gmail.com",
  port: 587,
  username: {:system, "SMTP_USERNAME"},
  password: {:system, "SMTP_PASSWORD"}

# Config arc
config :arc,
  storage_dir: "uploads"

config :facebook,
  app_id: System.get_env("FACEBOOK_APP_ID"),
  app_secret: System.get_env("FACEBOOK_APP_SECRET"),
  # or "https://graph.facebook.com/v2.11" to specify a version.
  graph_url: "https://graph.facebook.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
