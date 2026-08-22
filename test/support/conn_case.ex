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
    Frontier.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
