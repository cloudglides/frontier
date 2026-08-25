import Config

if File.exists?(Path.expand(".env")) do
  for line <-
        File.stream!(Path.expand(".env"))
        |> Stream.map(&String.trim/1)
        |> Stream.reject(&(String.starts_with?(&1, "#") || &1 == "")) do
    [key, value] = String.split(line, "=", parts: 2)
    System.put_env(String.trim(key), String.trim(value))
  end
end

if database_url = System.get_env("DATABASE_URL") do
  config :frontier, Frontier.Repo,
    url: database_url,
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    ssl: true,
    pool_size: 10
else
  config :frontier, Frontier.Repo,
    username: "postgres",
    password: "postgres",
    hostname: "localhost",
    database: "frontier_dev",
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
end

config :frontier, FrontierWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "bW4hE0az469i7qln4TD0wXCsHjgdJrngX2EYAmnqDt/SiXp2HNkj0kqhjrP2BPxk",
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

config :swoosh, :api_client, false
