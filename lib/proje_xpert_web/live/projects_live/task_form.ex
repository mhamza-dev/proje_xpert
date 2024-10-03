defmodule ProjeXpertWeb.ProjectsLive.TaskForm do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Task

  def update(%{task: task, project: project} = assigns, socket) do
    changeset = Tasks.change_task(task, %{project_id: project.id})
    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def update(%{task: task, projects: projects} = assigns, socket) do
    project = List.first(projects)
    columns = Tasks.project_columns(project.id)
    column = List.first(columns)
    changeset = Tasks.change_task(task, %{project_id: project.id, column_id: column.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       changeset: changeset,
       projects: Enum.map(projects, &{&1.title, &1.id}),
       columns: Enum.map(columns, &{&1.name, &1.id})
     )}
  end

  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Tasks.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case socket.assigns.action do
      action when action in [:projects_new_task, :bids_new_task] ->
        create_task(task_params, socket)

      :projects_edit_task ->
        update_task(task_params, socket)
    end
  end

  defp create_task(task_params, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{task.project_id}",
          {:task, task.project_id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_navigate(to: ~p"/projects/#{task.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_task(task_params, socket) do
    case Tasks.update_task(socket.assigns.task, task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast!(
          ProjeXpert.PubSub,
          "project:#{task.project_id}",
          {:task, task.project_id}
        )

        {:noreply,
         socket
         |> put_flash(:info, "task updated successfully")
         |> push_navigate(to: ~p"/projects/#{task.project_id}/show")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end
end
