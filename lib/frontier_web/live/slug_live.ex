defmodule FrontierWeb.SlugLive do
  use FrontierWeb, :live_view

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    {:ok, assign(socket, slug: slug)}
  end
end
