import Config

config :frontier, FrontierWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :frontier, FrontierWeb.Endpoint,
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: [
      hosts: ["localhost", "127.0.0.1"]
    ]
  ]

config :swoosh, api_client: Swoosh.ApiClient.Req

config :swoosh, local: false

config :logger, level: :info
