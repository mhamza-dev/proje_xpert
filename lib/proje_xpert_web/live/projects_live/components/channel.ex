defmodule ProjeXpertWeb.ProjectsLive.Components.Channel do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Chats

  def update(%{channel: channel, project: project} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset:
         Chats.change_channel(channel, %{joiners: [], name: "Channel for #{project.title}"}),
       joiners: []
     )}
  end

  def handle_event("validate", %{"channel" => channel_params}, socket) do
    joiners = get_selected_values(channel_params["joiners"])
    channel_params = Map.put(channel_params, "joiners", joiners)

    changeset =
      socket.assigns.channel
      |> Chats.change_channel(channel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, joiners: joiners)}
  end

  def handle_event("save", %{"channel" => channel_params}, socket) do
    joiners = get_selected_values(channel_params["joiners"])
    channel_params = Map.put(channel_params, "joiners", joiners)

    case Chats.create_channel(channel_params) do
      {:ok, channel} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.project.id}",
          {:column, socket.assigns.project.id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Column updated successfully")
         |> push_navigate(to: ~p"/projects/#{channel.project_id}/show")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
