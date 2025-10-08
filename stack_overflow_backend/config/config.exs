# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# Load environment variables from .env file first
if Code.ensure_loaded?(Dotenv) do
  Dotenv.load()
end

# General application configuration
import Config

config :stack_overflow_clone,
  ecto_repos: [StackOverflowClone.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :stack_overflow_clone, StackOverflowCloneWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: StackOverflowCloneWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: StackOverflowClone.PubSub,
  live_view: [signing_salt: "xPhBpyW1"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :stack_overflow_clone, StackOverflowClone.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Gemini configuration - will be set at runtime
config :gemini_ex,
  http_options: [recv_timeout: 60_000]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
