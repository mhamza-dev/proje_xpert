defmodule ProjeXpertWeb.ProjectsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project

  def mount(_params, _session, %{assigns: assigns} = socket) do
    {:ok, stream(socket, :projects, Tasks.list_client_projects(assigns.current_user.id))}
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

  defp get_all_bids_of_a_project(project, status) do
    project.tasks
    |> Enum.map(fn task ->
      Enum.filter(task.bids, fn bid -> bid.status == status end)
    end)
    |> Enum.reject(&Enum.empty?(&1))
    |> List.flatten()
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
    Enum.count(project.tasks, &(&1.status == :completed)) / Enum.count(project.tasks) * 100
  end
end
