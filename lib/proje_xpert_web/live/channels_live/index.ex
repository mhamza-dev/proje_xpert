defmodule ProjeXpertWeb.ChannelsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Chats
  alias ProjeXpert.Chats.Channel

  def mount(_params, _session, socket) do
    channels = get_resources_by_role(Channel, socket.assigns.current_user)
    {:ok, assign(socket, channels: channels)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Channel")
    |> assign(:channel, Chats.get_channel!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Channels")
    |> assign(:channel, nil)
  end
end
