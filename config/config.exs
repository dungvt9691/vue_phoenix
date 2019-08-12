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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
