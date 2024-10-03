defmodule ProjeXpertWeb.ProjectsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project

  def mount(params, _session, %{assigns: assigns} = socket) do
    projects = get_projects_by_role(assigns.current_user, params)

    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> stream(:projects, projects)}
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
end
