defmodule ProjeXpertWeb.ProjectsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Project

  def mount(params, _session, %{assigns: assigns} = socket) do
    projects = get_resources_by_role(Project, assigns.current_user, params)

    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> assign(:projects, projects)}
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

  def handle_event("search", %{"search" => search}, %{assigns: assigns} = socket) do
    projects =
      get_resources_by_role(
        Project,
        assigns.current_user,
        fetch_tab_param(assigns.current_tab),
        search
      )

    {:noreply, socket |> assign(:projects, projects)}
  end

  def handle_event("delete_project", %{"id" => id}, socket) do
    with %Project{} = project <- Tasks.get_project!(id),
         {:ok, _} <- Tasks.delete_project(project) do
      {:noreply,
       socket
       |> put_flash(:info, "Project deleted successfully")
       |> push_navigate(to: ~p"/projects")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Somehting went wrong while deleting the Project")
         |> push_navigate(to: ~p"/projects")}
    end
  end
end
