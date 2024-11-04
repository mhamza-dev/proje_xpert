defmodule ProjeXpertWeb.UserPresenceChannel do
  use ProjeXpertWeb, :channel

  alias ProjeXpertWeb.LiveHelpers
  alias ProjeXpertWeb.UserPresence, as: Presence

  @impl true
  def join("user_presence:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (user_presence:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, %{assigns: %{user: user}} = socket) do
    # Track the user in Presence
    Presence.track(socket, "user:#{LiveHelpers.full_name(user)}", %{
      user: user,
      online_at: NaiveDateTime.utc_now()
    })

    # Push the current online users to the client
    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  @impl true
  def handle_info(:after_join, socket), do: {:noreply, socket}
end
