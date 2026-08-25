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

    {:ok,
     assign(socket,
       viewer_count: viewer_count,
       unlocked: false
     )}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    viewer_count = map_size(Presence.list(@topic))

    {:noreply, assign(socket, :viewer_count, viewer_count)}
  end

  @impl true
  def handle_event("decode", %{"answer" => answer}, socket) do
    if String.downcase(String.trim(answer)) == "frontier" do
      {:noreply, assign(socket, :unlocked, true)}
    else
      {:noreply, socket}
    end
  end
end
