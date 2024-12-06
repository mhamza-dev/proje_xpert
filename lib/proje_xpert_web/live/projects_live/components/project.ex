defmodule ProjeXpertWeb.ProjectsLive.Components.Project do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Column, Project, Sprint}

  @default_params %{sprints: [%{title: ""}]}
  def update(%{project: project} = assigns, socket) do
    changeset = Project.create_changeset(project, @default_params)

    if project.status == :completed do
      send(self(), {:return_to_home, project})
    end

    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("add_sprint", _params, %{assigns: %{changeset: changeset}}= socket) do
    changeset = add_new_changeset(%Project{}, @default_params, changeset, :sprints)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("remove_sprint", %{"index" => index}, socket) do
    changeset = remove_changeset(socket.assigns.changeset, :sprints, index)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Project.create_changeset(project_params)
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
    with {:ok, project} <- Tasks.create_project(project_params),
         :ok <- create_columns(project) do
      {:noreply,
       socket
       |> put_flash(:info, "Project created successfully")
       |> push_navigate(to: ~p"/projects/#{project.id}/show")}
    else
      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_project(project_params, socket) do
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

  defp create_columns(project) do
    Enum.each(
      Column.get_default_columns(),
      &Tasks.create_column(%{name: &1, project_id: project.id, sprint_id: hd(project.sprints).id})
    )
  end
end
