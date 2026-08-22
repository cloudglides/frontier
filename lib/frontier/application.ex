defmodule Frontier.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FrontierWeb.Telemetry,
      Frontier.Repo,
      {DNSCluster, query: Application.get_env(:frontier, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Frontier.PubSub},
      FrontierWeb.Presence,
      FrontierWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Frontier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FrontierWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
