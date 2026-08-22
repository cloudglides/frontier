import Config

config :frontier, Frontier.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "frontier_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :frontier, FrontierWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "N676PlkU6y6NRSOKNpDgsVTSocp7xJnd+Z1xHcUA/2+jXsdsdQ4Aa6w2NtGvGcCj",
  server: false

config :frontier, Frontier.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :phoenix,
  sort_verified_routes_query_params: true
