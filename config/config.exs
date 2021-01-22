# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :fhub_web,
  ecto_repos: [FhubWeb.Repo],
  generators: [context_app: false]

# Configures the endpoint
config :fhub_web, FhubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "n5l2bdhS8JrMK2h0c1dF9FQjTeBULGZ5vONnfeCB98LpUMUnzpx9YlpWMb8jpZsp",
  render_errors: [view: FhubWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FhubWeb.PubSub,
  live_view: [signing_salt: "WaJ1tZtz"]

# Configure Mix tasks and generators
config :fhub,
  ecto_repos: [Fhub.Repo]

config :fhub_web,
  ecto_repos: [Fhub.Repo],
  generators: [context_app: :fhub, binary_id: true]

# Configures the endpoint
config :fhub_web, FhubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wa6jdyOLmWQ8u73nAMNN6sGcBksIj2Q977oTlLeDywc7O+1CGWBoHuArNjDFZqZD",
  render_errors: [view: FhubWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fhub.PubSub,
  live_view: [signing_salt: "9diS8EXv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
