defmodule Frontier.Release do
  @moduledoc """
  Runs migrations for a release, e.g.:

      bin/frontier eval Frontier.Release.migrate
  """

  require Logger

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(:frontier, :ecto_repos)
  end

  defp load_app do
    Application.load(:frontier)
  end
end
