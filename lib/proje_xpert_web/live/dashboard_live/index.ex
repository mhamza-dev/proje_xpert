defmodule ProjeXpertWeb.DashboardLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Chart
  alias ProjeXpert.Tasks.Project

  def mount(params, _session, socket) do
    projects = get_resources_by_role(Project, socket.assigns.current_user, params)

    {:ok,
     assign(socket,
       projects: projects,
       active_project: active_projects(projects),
       hired_freelancers: hired_freelancers(projects),
       completed_projects: completed_projects(projects)
     )}
  end

  defp active_projects(projects) do
    projects
    |> Enum.filter(&(&1.status == :in_progress))
    |> length
  end

  defp completed_projects(projects) do
    projects
    |> Enum.filter(&(&1.status == :in_progress))
    |> length
  end

  defp hired_freelancers(projects) do
    projects
    |> Enum.flat_map(& &1.tasks)
    |> Enum.uniq_by(& &1.freelancer_id)
    |> Enum.count()
  end

  defp recent_projects(projects) do
    start_of_month = DateTime.utc_now() |> DateTime.shift(day: -1)

    projects
    |> Enum.filter(&(DateTime.compare(&1.inserted_at, start_of_month) != :lt))
    |> Enum.take(3)
  end
end
