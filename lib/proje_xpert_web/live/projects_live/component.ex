defmodule ProjeXpertWeb.ProjectsLive.Component do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project

  def update(%{project: project} = assigns, socket) do
    changeset = Tasks.change_project(project, %{})
    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Tasks.change_project(project_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    case socket.assigns.action do
      :edit ->
        update_project(project_params, socket)

      :new ->
        create_project(project_params, socket)
    end
  end

  defp create_project(project_params, socket) do
    case Tasks.create_project(project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(to: ~p"/projects/#{project.id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def update_project(project_params, socket) do
    case Tasks.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{socket.assigns.project.id}",
          {:project_update, socket.assigns.project.id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(to: ~p"/projects/#{project.id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end
end
