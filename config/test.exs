import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :parallel_sandbox, ParallelSandbox.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "parallel_sandbox_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 100

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :parallel_sandbox, ParallelSandboxWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ygnlPcsId0t36eu9uvsff68dyrCEzAuDWzV/IOIdXgdV42vaoaXfRdhrIlyZeRNX",
  server: true

# In test we don't send emails.
config :parallel_sandbox, ParallelSandbox.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
# config :logger, level: :warning
config :logger,
  level: :error,
  format: "[$level] $message\n",
  backends: [:console]

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
