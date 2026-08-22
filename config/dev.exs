import Config

config :frontier, Frontier.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "frontier_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :frontier, FrontierWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "h+rpjPkwoN//Yon5BJP3zJQrl7tYBXmTkp3TaO6s7lvToNcuiYxxzSO2lSLkZKZD",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:frontier, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:frontier, ~w(--watch)]}
  ]


config :frontier, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

config :swoosh, :api_client,