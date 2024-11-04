defmodule ProjeXpertWeb.ChannelsLive.Show do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Chats
  alias ProjeXpert.Chats.Message

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ProjeXpert.PubSub, "Channel:#{id}")
    {:ok, socket}
  end

  def handle_params(%{"id" => id} = _params, _url, socket) do
    channel = Chats.get_channel!(id)
    message = %Message{}

    {:noreply,
     socket
     |> assign(
       channel: channel,
       joiners: Accounts.list_users_by_ids(channel.joiners),
       changeset: Chats.change_message(message),
       message: message,
       messages: channel.messages
     )}
  end

  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset =
      socket.assigns.message
      |> Chats.change_message(message_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("send", %{"message" => message_params}, socket) do
    case Chats.create_message(message_params) do
      {:ok, message} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "Channel:#{message.channel_id}",
          {:new_message, message.channel_id}
        )

        {:noreply, socket |> push_navigate(to: ~p"/channels/#{message.channel_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def handle_info({:new_message, id}, socket) do
    channel = Chats.get_channel!(id)
    {:noreply, assign(socket, channel: channel, messages: channel.messages)}
  end

  def get_sender(%{joiners: joiners, channel: channel}, sender_id) do
    Enum.find(joiners ++ [channel.project.client], &(&1.id == sender_id))
  end
end
