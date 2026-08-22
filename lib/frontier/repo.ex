defmodule Frontier.Repo do
  use Ecto.Repo,
    otp_app: :frontier,
    adapter: Ecto.Adapters.Postgres
end
