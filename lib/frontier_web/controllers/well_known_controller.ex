defmodule FrontierWeb.WellKnownController do
  use FrontierWeb, :controller

  def chrome_devtools(conn, _params), do: send_resp(conn, :no_content, "")
end
