defmodule FrontierWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint FrontierWeb.Endpoint

      use FrontierWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import FrontierWeb.ConnCase
    end
  end

  setup tags do
    if tags[:db] do
      Frontier.DataCase.setup_sandbox(tags)
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
