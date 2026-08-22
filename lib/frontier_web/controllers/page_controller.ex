defmodule FrontierWeb.PageController do
  use FrontierWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
