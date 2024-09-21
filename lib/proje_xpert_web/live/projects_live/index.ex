defmodule ProjeXpertWeb.ProjectsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project

  def mount(_params, _session, %{assigns: assigns} = socket) do
    function = get_projects_by_role(assigns.current_user.role)
    {:ok, stream(socket, :projects, function.(assigns.current_user.id))}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Tasks.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Projects")
    |> assign(:project, nil)
  end

  defp get_worker_ids_of_a_project(project) do
    project.tasks
    |> Enum.flat_map(fn task ->
      task.worker_tasks
      |> Enum.filter(fn wt -> wt.worker_id end)
      |> Enum.map(& &1.worker_id)
    end)
    |> Enum.uniq()
  end

  defp get_tailwind_width_class(project) do
    percentage = get_percentage(project)

    cond do
      percentage <= 24 -> "w-0/4"
      percentage >= 25 and percentage <= 49 -> "w-1/4"
      percentage >= 50 and percentage <= 74 -> "w-1/2"
      percentage >= 75 and percentage <= 99 -> "w-3/4"
      true -> "w-full"
    end
  end

  defp get_percentage(project) do
    Enum.count(project.tasks, &(&1.column.name == "Completed")) / Enum.count(project.tasks) * 100
  end

  defp get_projects_by_role(role) do
    if role == :client do
      &Tasks.list_client_projects/1
    else
      &Tasks.list_worker_projects/1
    end
  end
end
