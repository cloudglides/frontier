defmodule FrontierWeb.PageLive do
  use FrontierWeb, :live_view

  alias FrontierWeb.Presence

  @topic "viewers"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Frontier.PubSub, @topic)

      Presence.track(self(), @topic, socket.id, %{})
    end

    viewer_count = map_size(Presence.list(@topic))

    socket = assign(socket, viewer_count: viewer_count)

    {:ok, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    viewer_count = map_size(Presence.list(@topic))

    socket = assign(socket, viewer_count: viewer_count)

    {:noreply, socket}
  end
end
