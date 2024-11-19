defmodule ProjeXpertWeb.ProjectsLive.Components.Sprint do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks

  def update(%{project: project, sprint: sprint} = assigns, socket) do
    changeset = Tasks.change_sprint(sprint, %{project_id: project.id})

    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"sprint" => sprint_params}, socket) do
    changeset =
      socket.assigns.sprint
      |> Tasks.change_sprint(sprint_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"sprint" => sprint_params}, socket) do
    case socket.assigns.action do
      :new_sprint ->
        create_sprint(sprint_params, socket)

      :edit_sprint ->
        update_sprint(sprint_params, socket)
    end
  end

  defp create_sprint(sprint_params, socket) do
    case Tasks.create_sprint(sprint_params) do
      {:ok, sprint} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.project.id}",
          {:sprint, socket.assigns.project.id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Sprint created successfully")
         |> push_navigate(to: ~p"/projects/#{sprint.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_sprint(sprint_params, socket) do
    case Tasks.update_sprint(socket.assigns.sprint, sprint_params) do
      {:ok, sprint} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.project.id}",
          {:sprint, socket.assigns.project.id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Sprint updated successfully")
         |> push_navigate(to: ~p"/projects/#{sprint.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end
end
